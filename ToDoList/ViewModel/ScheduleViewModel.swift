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
    let startEpochInputRelay = BehaviorRelay<Double>(value: 0)
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
    let startEpochOutputRelay = BehaviorRelay<Double>(value: 0)
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
        
        // epoch 타임을 받아옴
        startEpochInputRelay
            .subscribe(onNext: { [weak self] in
                let date = Date(timeIntervalSince1970: $0)
                guard let dateString = self?.dateFormatter.string(from: date) else {return}
                self?.dateStringRelay
                    .accept(dateString)
                self?.startTime = date
                self?.startEpochOutputRelay
                    .accept($0)
            })
            .disposed(by: disposeBag)
        
        bindPicker()
        var schedule = initSchedule()
        Observable.combineLatest(editableRelay, scheduleRelay)
            .filter {$0 == true && $1 != nil}
            .subscribe(onNext: { [weak self] in
                print("editmode schedule")
                schedule = self?.getSchedule($1!.objectID)
            })
            .disposed(by: disposeBag)
        
        _ = Observable
            .combineLatest(scheduleTitleRelay, startEpochOutputRelay, alarmRelay, scheduleContentsRelay)
            .filter({(title, epoch, alarm, contents) in !title.isEmpty && !contents.isEmpty})
            .subscribe (onNext:{ [unowned self] (title, epoch, alarm, contents) in
                let date = Date(timeIntervalSince1970: epoch).toLocalTime()
                print(date)
//                print(title, date, alarm, contents)
//                self.setSchedule(schedule, title, date, alarm, contents)
//                self.setAlarm(alarm, title, date, contents)
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
    
    func bindPicker(){
        let notificationTimeObservable = Observable
            .combineLatest(startEpochInputRelay, pickerHourRelay, pickerMinuteRelay)
        
        notificationTimeObservable
            .subscribe(onNext: { [weak self] in
                self?.startEpochOutputRelay
                    .accept($0 + Double($1 * 3600) + Double($2 * 60))
            })
            .disposed(by: disposeBag)
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
        // start를 UTC로 저장함.
        print("setSchedule", start)
//        schedule.setValue(start, forKey: "start")
        // 저장할 때는 UTC??
        // KST
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
        
        var startTimeDateComponents = DateComponents(year: startTime.year, month: startTime.month,
                                                     day: startTime.day, hour: startTime.hour, minute: startTime.minute)
        startTimeDateComponents.timeZone = TimeZone(identifier: "Asia/Seoul")
        let trigger = UNCalendarNotificationTrigger(dateMatching: startTimeDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "papayetoo.toDoList", content: alarmContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print("UserNofification 등록 완료")
    }
    
}
