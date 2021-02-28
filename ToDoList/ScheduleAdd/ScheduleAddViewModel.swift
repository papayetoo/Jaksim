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

class ScheduleAddViewModel{
    let scheduleTitleRelay = BehaviorRelay<String>(value: "")
    let startTimeRelay = BehaviorRelay<Date>(value: Date())
    let alarmRelay = BehaviorRelay<Int>(value: 0)
    let scheduleContentsRelay = PublishRelay<String>()
    let saveButtonTouchedRelay = PublishRelay<Void>()
    let saveButtonEnableRelay = BehaviorRelay<Bool>(value: false)
    var disposeBag = DisposeBag()
    
    init() {
        let context = PersistantManager.shared.context
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else
        {return}

        
        _ = Observable.combineLatest(scheduleTitleRelay, scheduleContentsRelay)
            .map({(title, contents) -> Bool in  !title.isEmpty && !contents.isEmpty })
            .distinctUntilChanged()
            .bind(to: saveButtonEnableRelay)
            .disposed(by: disposeBag)
        
        saveButtonEnableRelay.subscribe(onNext: {
            print("save button Enable: \($0)")
        })
        
        let schedule = NSManagedObject(entity: entity, insertInto: context)
        _ = Observable
            .combineLatest(scheduleTitleRelay, startTimeRelay, alarmRelay, scheduleContentsRelay)
            .filter({(title, date, alarm, contents) in !title.isEmpty && !contents.isEmpty})
            .subscribe (onNext:{ (title, date, alarm, contents) in
                print(title, date, alarm, contents)
                schedule.setValue(title, forKey: "title")
                schedule.setValue(date, forKey: "start")
                schedule.setValue(alarm == 0 ? true : false, forKey: "alarm")
                schedule.setValue(contents, forKey: "contents")
            })
            .disposed(by: disposeBag)
        
        _ = saveButtonTouchedRelay.subscribe(onNext: {
            print("save button touched")
                do {
                    try context.save()
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
    
}
