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

struct ScheduleAddViewModel{
    let scheduleTitleRelay = PublishRelay<String>()
    let startTimeRelay = PublishRelay<Date>()
    let alarmRelay = PublishRelay<Int>()
    let scheduleContentsRelay = PublishRelay<String>()
    let saveButtonTouchedRelay = PublishRelay<Void>()
    
    
    
    init() {
        let context = PersistantManager.shared.context
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else
        {return}
        let schedule = NSManagedObject(entity: entity, insertInto: context)
        let object = Observable.combineLatest(scheduleTitleRelay, startTimeRelay, alarmRelay, scheduleContentsRelay).subscribe (onNext:{ (title, date, alarm, contents) in
            schedule.setValue(title, forKey: "title")
            schedule.setValue(date, forKey: "start")
            if alarm == 1 {
                schedule.setValue(true, forKey: "alarm")
            } else {
                schedule.setValue(false, forKey: "alarm")
            }
            schedule.setValue(contents, forKey: "contents")
        })
        _ = saveButtonTouchedRelay.subscribe(onNext: {
            do {
                try context.save()
                print("Save a new schedule to Core Data 성공")
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    
    func getValidTitleObservable() -> Observable<String> {
        return scheduleTitleRelay.filter{ $0 != "" }.asObservable()
    }
    
}
