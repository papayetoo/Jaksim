//
//  SheduleViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/15.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

class ScheduleViewModel {
    
    private let context = PersistantManager.shared.context
    var selectedDatesRelay: PublishRelay<[Date]> = PublishRelay()
    var monthScheduleRelay: PublishRelay<[[Schedule]]> = PublishRelay()
    var schedulesRelay: PublishRelay<[[Schedule]]> = PublishRelay()
    var singleScheduleRelay: PublishRelay<Schedule?> = PublishRelay()
    private let schedule: Schedule?
    let currentMonthRelay: PublishRelay<Date> = PublishRelay()
    private let disposeBag = DisposeBag()
    
    init(schedule: Schedule?){
        self.schedule = schedule
        self.singleScheduleRelay.accept(schedule)
    }
    
    init() {
        
        schedule = nil
        
        // MARK: 선택된 날들에 대해서 스케쥴을 가져옴.
        selectedDatesRelay.map({ dates in
            dates.map { [weak self] in
                self?.fetchSchedules(of: $0) ?? [] }
        })
        .bind(to: schedulesRelay)
        .disposed(by: disposeBag)
        
        // MARK: 현재 달에 존재하는 스케쥴의 수를 monthScheudleRelay로 전달
        currentMonthRelay.map({ startOfMonth in
            let schedulesOfMonth = stride(from: startOfMonth.toLocalTime().startOfDay,
                   to: startOfMonth.endOfMonth.toLocalTime().endOfDay,
                   by: 24 * 60 * 60).map { [weak self] in
                    self?.fetchSchedules(of: $0)
            }
            return schedulesOfMonth.compactMap({$0})
        }).bind(to: monthScheduleRelay)
        .disposed(by: disposeBag)
        
        monthScheduleRelay.subscribe(onNext: { schedules in
            schedules.map {
                print($0.count)
            }
        })
        
    }
    
    private func fetchSchedules(of date: Date) -> [Schedule]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
        let letfPredicate = NSPredicate(format: "start >= %@", date.startOfDay.toLocalTime() as NSDate)
        let rightPredicate = NSPredicate(format: "start <= %@", date.endOfDay.toLocalTime() as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [letfPredicate, rightPredicate])
        
        do {
            let schedules = try context.fetch(request) as? [Schedule]
            return schedules
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }


}
