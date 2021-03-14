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
    // MARK: title, contents ---> button enable
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
    private var startEpoch: Double = 0
    
    fileprivate let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
    
    fileprivate let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
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
                self?.startEpochOutputRelay
                    .accept($0)
                print("timestring", self?.timeFormatter.string(from: date))
                let dateComponents = Calendar(identifier: .gregorian).dateComponents([.hour, .minute], from: date)
                print("timestring", dateComponents.hour, dateComponents.minute)
                self?.pickerHourRelay
                    .accept(dateComponents.hour ?? 0)
                self?.pickerMinuteRelay
                    .accept(dateComponents.minute ?? 0)
            })
            .disposed(by: disposeBag)
        
        startEpochOutputRelay
            .bind(onNext: {[weak self] in self?.startEpoch = $0})
            .disposed(by: disposeBag)
        
        bindPicker()
        var schedule: NSManagedObject?
//        Observable.combineLatest(editableRelay, scheduleRelay)
//            .filter {$0 == true && $1 != nil}
//            .subscribe(onNext: { [weak self] in
//                print("editmode schedule")
//                schedule = self?.getSchedule($1!.objectID)
//                print("")
//            })
//            .disposed(by: disposeBag)
        editableRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                print("editableRelay", $0)
                if $0 {
                    
                    guard let scheduleID = self?.scheduleRelay.value?.objectID else {return}
                    schedule = self?.getSchedule(scheduleID)
                    print("편집 ")
                } else {
                    schedule = self?.initSchedule()
                    print("작성 ")
                }
            })
            .disposed(by: disposeBag)
        
         
        _ = saveButtonTouchedRelay.subscribe(onNext: { [unowned self] in
            let schedule = scheduleRelay.value ?? initSchedule()
            let title = scheduleTitleRelay.value
            let epoch = startEpochOutputRelay.value
            let alarm = alarmRelay.value
            let contents = scheduleContentsRelay.value
            let notiId = "papayetoo.TodoList.\(Date().timeIntervalSince1970)"
            if schedule?.value(forKey: "notiId") == nil {
                schedule?.setValue(notiId, forKey: "notiId")
            }
            schedule?.setValue(title, forKey: "title")
            // 일정 시작 시간을 저장할 때는 항상 epoch time
            schedule?.setValue(startEpoch, forKey: "startEpoch")
            schedule?.setValue(alarm == 0 ? true : false, forKey: "alarm")
            schedule?.setValue(contents, forKey: "contents")
            self.setAlarm(alarm, title, epoch, contents)
                do {
                    try context.save()
                    if alarm == 0 {
                        self.setAlarmTrigger(schedule)
                    } else {
                        self.removeNotificationRequest(schedule)
                    }
                    print("Save a new schedule to Core Data 성공")
                } catch {
                    print(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        scheduleRelay
            .subscribe(onNext: { [weak self] in
                guard let startEpoch = $0?.startEpoch, let title = $0?.title, let contents = $0?.contents, let isAlarm = $0?.alarm else {return}
                self?.alarmRelay
                    .accept(isAlarm == true ? 0 : 1)
                self?.scheduleTitleRelay
                    .accept(title)
                self?.startEpochInputRelay
                    .accept(startEpoch)
                self?.scheduleContentsRelay
                    .accept(contents)
            })
            .disposed(by: disposeBag)
    }
    
    func bindPicker(){
        Observable
            .combineLatest(startEpochInputRelay, pickerHourRelay.distinctUntilChanged(), pickerMinuteRelay.distinctUntilChanged())
            .subscribe(onNext: { [weak self] in
                let epoch = Date(timeIntervalSince1970: $0).startOfDay.timeIntervalSince1970
                self?.startEpochOutputRelay
                    .accept(epoch + Double($1) * 3600 + Double($2) * 60)
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
        let schedule = context.object(with: id) as? Schedule
        print("getSchedule", schedule?.title, schedule?.contents)
        return schedule
    }
    
    // MARK: CoreData에 삽입할 schedule 생성
    fileprivate func setSchedule(_ schedule: inout NSManagedObject?, _ title: String, _ startEpoch: Double, _ alarm: Int, _ contents: String) {
        guard let schedule = schedule else {return}
        schedule.setValue(title, forKey: "title")
        // 일정 시작 시간을 저장할 때는 항상 epoch time
        print("setSchedule", timeFormatter.string(from: Date(timeIntervalSince1970: startEpoch)))
        schedule.setValue(startEpoch, forKey: "startEpoch")
        schedule.setValue(alarm == 0 ? true : false, forKey: "alarm")
        schedule.setValue(contents, forKey: "contents")
    }
    
    // MARK: 알림 컨텐츠 설정
    fileprivate func setAlarm(_ isAlarmOn: Int, _ scheduleTitle: String, _ startEpoch: Double, _ scheduleContents: String) {
        if isAlarmOn == 1 {
            return
        }
        let date = Date(timeIntervalSince1970: startEpoch)
        self.alarmContent = UNMutableNotificationContent()
        self.alarmContent?.title = scheduleTitle
        self.alarmContent?.subtitle = "일정을 확인하세요."
        self.alarmContent?.sound = UNNotificationSound.default
        // DateFormatter 가 TimeZone에 맞게 변환해줌 따라서 local 시간을 넣을 필요가 없음
        self.alarmContent?.body = "\(timeFormatter.string(from: date)) \(scheduleContents)"
        self.alarmContent?.badge = 1
    }
    
    // MARK: StartTime에 맞춰 알림 설정
    fileprivate func setAlarmTrigger(_ schedule: NSManagedObject?) {
        guard let schedule = schedule as? Schedule, let notiId = schedule.notiId, let alarmContent = self.alarmContent else {return}
        let date = Date(timeIntervalSince1970: schedule.startEpoch)
        // DateComponents 가 자동으로 타임존을 Asia/Seoul로 잡음
        let startTimeDateComponents = DateComponents(year: date.year, month: date.month,
                                                     day: date.day, hour: date.hour, minute: date.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: startTimeDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notiId, content: alarmContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    fileprivate func removeNotificationRequest(_ schedule: NSManagedObject?) {
        guard let schedule = schedule as? Schedule, let notiId = schedule.notiId else {return}
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notiId])
//        UNUserNotificationCenter.current().getPendingNotificationRequests {
//            for request:UNNotificationRequest in $0 {
//                print(request.identifier)
//            }
//        }
    }
    
}
