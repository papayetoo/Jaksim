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

class ScheduleAddViewModel{
    let selectedDateSubject = BehaviorSubject<Date>(value: Date())
    let scheduleTitleRelay = BehaviorRelay<String>(value: "")
    let startTimeRelay = BehaviorRelay<Date>(value: Date())
    let dateStringRelay = BehaviorRelay<String>(value: "")
    let alarmRelay = BehaviorRelay<Int>(value: 0)
    let scheduleContentsRelay = BehaviorRelay<String>(value: "")
    let saveButtonTouchedRelay = PublishRelay<Void>()
    let saveButtonEnableRelay = BehaviorRelay<Bool>(value: false)
    
    var disposeBag = DisposeBag()
    
    // MARK: Alarm Contents
    private var alarmContent: UNMutableNotificationContent?
    // MARK: CoreData context
    private let context = PersistantManager.shared.context
    // MARK: StartTim Date Object
    private var startTime: Date = Date()
    
    fileprivate let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 d일"
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
        
        startTimeRelay.map {[unowned self] date in
            self.dateFormatter.string(from: date)
        }.bind(to: dateStringRelay)
        .disposed(by: disposeBag)
        
        startTimeRelay
            .bind(onNext: {[unowned self] date in self.startTime = date})
            .disposed(by: disposeBag)
        

        let schedule = initSchedule()
        _ = Observable
            .combineLatest(scheduleTitleRelay, startTimeRelay, alarmRelay, scheduleContentsRelay)
            .filter({(title, date, alarm, contents) in !title.isEmpty && !contents.isEmpty})
            .subscribe (onNext:{ [unowned self] (title, date, alarm, contents) in
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
    
    func checkValid(_ title: String, _ contents: String) -> Bool {
        return (title.components(separatedBy: " ").count == 0 || contents.components(separatedBy: " ").count == 0)
    }
    
    // MARK: CoreData에 삽입 전 entity, schedule 초기화 작업
    fileprivate func initSchedule() -> NSManagedObject? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else {return nil}
        let schedule = NSManagedObject(entity: entity, insertInto: context)
        return schedule
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
