//
//  ScheduleAddViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/20.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import UserNotifications

class ScheduleViewModel{
    let selectedDateSubject = BehaviorSubject<Date>(value: Date())
    let scheduleTitleRelay = BehaviorRelay<String>(value: "")
    let startTimeInputRelay = BehaviorRelay<Date>(value: Date())
    let dateStringRelay = BehaviorRelay<String>(value: "")
    let alarmRelay = BehaviorRelay<Int>(value: 0)
    let scheduleContentsRelay = BehaviorRelay<String>(value: "")
    // MARK: time string 받아오기 위한 변수
    let pickerHourRelay = BehaviorRelay<Int>(value: 0)
    // MARK: time minute 받아오기 위한 변수
    let pickerMinuteRelay = BehaviorRelay<Int>(value: 0)
    // MARK: time string 을 돌려줌.
    let pickerTimeRelay = BehaviorRelay<String>(value: "")
    // MARK: save button touch 감지
    let saveButtonTouchedRelay = PublishRelay<Void>()
    // MARK: title이 입력된 상태이고, contents가 존재할 때 enable
    let saveButtonEnableRelay = BehaviorRelay<Bool>(value: false)
    // MARK: schedule을 갖는 relay 형성
    let scheduleRelay = BehaviorRelay<Schedule?>(value: nil)
    
    let editableRelay = BehaviorRelay<Bool>(value: false)
    let alarmTimeRelay = BehaviorRelay(value: Date())
    var disposeBag = DisposeBag()
    
    // MARK: Alarm Contents
    private var alarmContent: UNMutableNotificationContent?
    // MARK: CoreData context
    private let context = PersistantManager.shared.context
    // MARK: StartTim Date Object
    private var startTime: Date = Date()
    
    fileprivate let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
    
    fileprivate let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "[HH:mm]"
        return formatter
    }()
    
    init() {
        _ = Observable.combineLatest(scheduleTitleRelay, scheduleContentsRelay)
            .map({(title, contents) -> Bool in  !title.isEmpty && !contents.isEmpty })
            .distinctUntilChanged()
            .bind(to: saveButtonEnableRelay)
            .disposed(by: disposeBag)
        
        startTimeInputRelay
            .map {[unowned self] date in
            self.dateFormatter.string(from: date)
            }
            .bind(to: dateStringRelay)
            .disposed(by: disposeBag)
        
        startTimeInputRelay
            .bind(onNext: {[unowned self] date in self.startTime = date})
            .disposed(by: disposeBag)
        
        setAlarmTime()
        
        var schedule = initSchedule()
        Observable.combineLatest(editableRelay, scheduleRelay)
            .filter {$0 == true && $1 != nil}
            .subscribe(onNext: { [weak self] in
                print("editmode schedule")
                schedule = self?.getSchedule($1!.objectID)
            })
            .disposed(by: disposeBag)
        
        _ = Observable
            .combineLatest(scheduleTitleRelay, alarmTimeRelay, alarmRelay, scheduleContentsRelay)
            .filter({(title, date, alarm, contents) in !title.isEmpty && !contents.isEmpty})
            .subscribe (onNext:{ [unowned self] (title, date, alarm, contents) in
                print(title, date.toLocalTime(), alarm, contents)
                self.setSchedule(schedule, title, date, alarm, contents)
                self.setAlarm(alarm, title, date, contents)
            })
            .disposed(by: disposeBag)
         
        _ = saveButtonTouchedRelay.subscribe(onNext: { [unowned self] in
            print("save button touched")
                do {
                    try context.save()
                    self.setAlarmTrigger()
                    print("Save a new schedule to Core Data 성공")
                } catch {
                    print(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setAlarmTime(){
        let notificationTimeObservable = Observable
                                        .combineLatest(pickerHourRelay, pickerMinuteRelay)
        notificationTimeObservable
            .subscribe(onNext: { [weak self] in
                self?.pickerTimeRelay.accept("\($0)시 \($1)분")
                let newStartTime = DateComponents(year: self?.startTime.year, month: self?.startTime.month, day: self?.startTime.day, hour: $0, minute: $1)
                self?.startTime = Calendar(identifier: .gregorian).date(from: newStartTime) ?? Date()
                self?.alarmTimeRelay.accept(self?.startTime ?? Date())
            })
            .disposed(by: disposeBag)
    }
    
    func checkValid(_ title: String, _ contents: String) -> Bool {
        return (title.components(separatedBy: " ").count == 0 || contents.components(separatedBy: " ").count == 0)
    }
    
    // MARK: CoreData에 삽입 전 entity, schedule 초기화 작업
    fileprivate func initSchedule() -> NSManagedObject? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else {return nil}
        let schedule = NSManagedObject(entity: entity, insertInto: context)
        return schedule
    }
    
    // MARK: CoreData에 업데이트 하기 위해서 Schedule 가져옴.
    fileprivate func getSchedule(_ id: NSManagedObjectID) -> Schedule? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
        do {
            let schedule = try context.object(with: id) as? Schedule
            NSPredicate(format: <#T##String#>, <#T##args: CVarArg...##CVarArg#>)
//            print("getSchedule", schedule?.title, schedule?.contents)
            return schedule
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: CoreData에 삽입할 schedule 생성
    fileprivate func setSchedule(_ schedule: NSManagedObject?, _ title: String, _ start: Date, _ alarm: Int, _ contents: String) {
        guard let schedule = schedule else {return}
        schedule.setValue(title, forKey: "title")
        schedule.setValue(start, forKey: "start")
        schedule.setValue(alarm == 0 ? true : false, forKey: "alarm")
        schedule.setValue(contents, forKey: "contents")
    }
    
    // MARK: 알림 컨텐츠 설정
    fileprivate func setAlarm(_ isAlarmOn: Int, _ scheduleTitle: String, _ start: Date, _ scheduleContents: String) {
        if isAlarmOn == 1 {
            return
        }
        self.alarmContent = UNMutableNotificationContent()
        self.alarmContent?.title = "작심"
        self.alarmContent?.subtitle = scheduleTitle
        self.alarmContent?.sound = UNNotificationSound.default
        self.alarmContent?.body = "\(timeFormatter.string(from: start))\(scheduleContents)"
        self.alarmContent?.badge = 1
    }
    
    // MARK: StartTime에 맞춰 알림 설정
    fileprivate func setAlarmTrigger() {
        guard let alarmContent = self.alarmContent else {return}
        
        let startTimeDateComponents = DateComponents(year: startTime.year, month: startTime.month,
                                                     day: startTime.day, hour: startTime.hour, minute: startTime.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: startTimeDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "papayetoo.toDoList", content: alarmContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print("UserNofification 등록 완료")
    }
    
}
