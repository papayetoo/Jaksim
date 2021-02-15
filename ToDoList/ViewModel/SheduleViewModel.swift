//
//  SheduleViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/15.
//

import Foundation
import RxSwift

class ScheduleViewModel {
    var scheduleSubject: BehaviorSubject<Schedule?>
    private let schedule: Schedule?
    
    init(schedule: Schedule?){
        self.schedule = schedule
        self.scheduleSubject = BehaviorSubject(value: self.schedule)
    }
}
