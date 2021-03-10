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

class ToDoViewModel {
    
    private let context = PersistantManager.shared.context
    // MARK: toDoCalendar에서 선택된 날과 바인딩
    var selectedDatesRelay: PublishRelay<[Date]> = PublishRelay()
    // MARK: selectedDates 를 저장 중..
    var selectedDates: [Date] = []
    // MARK: eventForDate와 연동하기 위한 Relay
    var eventForDateInputRelay: PublishRelay<Date> = PublishRelay()
    var eventForDateOutputRelay: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    var monthScheduleRelay: PublishRelay<[[Schedule]]> = PublishRelay()
    var schedulesRelay: PublishRelay<[[Schedule]]> = PublishRelay()
    var singleScheduleRelay: PublishRelay<Schedule?> = PublishRelay()
    private var schedule: Schedule? = nil
    let currentMonthRelay: PublishRelay<Date> = PublishRelay()
    let eventsAtDateSubject: BehaviorSubject<[Date:Int]> = BehaviorSubject(value: [:])
    // MARK: ScheduleTableView에서 row에 있는 스케쥴과 data binding
    let selectedScheduleRelay: BehaviorRelay<Schedule?> = BehaviorRelay(value: nil)
    var selectedSchedule: Schedule? = nil
    // MARK: 삭제버튼과 바인딩
    let deletedActionRelay: PublishRelay<Void> = PublishRelay()
    
    private let disposeBag = DisposeBag()
    
    init(schedule: Schedule?){
        self.schedule = schedule
        self.singleScheduleRelay.accept(schedule)
    }
    
    init() {
        
        // MARK: 선택된 날들에 대해서 스케쥴을 가져옴.
        // selectedDatesRelay ----> schedulesRelay
        selectedDatesRelay.map({ dates in
            dates.map { [weak self] in
                self?.fetchSchedules(of: $0) ?? [] }
        })
        .bind(to: schedulesRelay)
        .disposed(by: disposeBag)
        
        // MARK: 선택된 날들을 별도의 변수에 저장
        selectedDatesRelay
            .subscribe(onNext: { [weak self] in
            self?.selectedDates = $0
            })
            .disposed(by: disposeBag)
        
        // MARK: 현재 달에 존재하는 스케쥴의 수를 monthScheudleRelay로 전달
        currentMonthRelay.map({ startOfMonth in
            let schedulesOfMonth = stride(from: startOfMonth.toLocalTime().startOfDay,
                   to: startOfMonth.endOfMonth.toLocalTime().endOfDay,
                   by: 24 * 60 * 60).map { [weak self] in
                    self?.fetchSchedules(of: $0)
            }
            return schedulesOfMonth.compactMap({$0})
        })
        .bind(to: monthScheduleRelay)
        .disposed(by: disposeBag)
        
        // MARK: 현재 선택된 월에 존재하는 일을 모두 가져옴.
        let monthSchedulesCountRelay = monthScheduleRelay
            .map({ schedulesOfDays -> [Int] in
                let schedulesOfDaysCount = schedulesOfDays.map {$0.count}
                return schedulesOfDaysCount
            })
        
        // MARK: 삭제시 원하는 스케쥴의 정보를 subscribe
        selectedScheduleRelay
            .subscribe(onNext: { [weak self] in
                self?.selectedSchedule = $0
            })
            .disposed(by: disposeBag)
        
        // MARK: 삭제 액션 실행 시
        deletedActionRelay
            .subscribe(onNext: { [weak self] _ in
                guard let toDeleteSchedule = self?.selectedSchedule, let selectedDates = self?.selectedDates else {return}
                // 선택된 스케쥴에 대해서 CoreData 삭제 실행
                self?.deleteSchedule(toDeleteSchedule)
                // 새로 스케쥴 불러옴
                guard let updateSchedules = self?.selectedDates.map({ [weak self] date in
                    self?.fetchSchedules(of: date)
                }).compactMap({$0}) else {return}
                self?.schedulesRelay.accept(updateSchedules)
            })
            .disposed(by: disposeBag)
        
        // MARK: eventsForDate
        eventForDateInputRelay
            .map {[weak self] date -> [Schedule]? in return self?.fetchSchedules(of: date)}
            .map {return $0?.count ?? 0}
            .bind(to: eventForDateOutputRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: CoreData로 부터 해당 날짜에 해당하는 스케쥬을 불러옴.
    private func fetchSchedules(of date: Date) -> [Schedule]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
        let letfPredicate = NSPredicate(format: "start >= %@", date.startOfDay.toLocalTime() as NSDate)
        let rightPredicate = NSPredicate(format: "start <= %@", date.endOfDay.toLocalTime() as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [letfPredicate, rightPredicate])
        
        do {
            var schedules = try context.fetch(request) as? [Schedule]
            schedules?.sort(by: {
                guard let leftScheduleStart = $0.start, let rightScheduleStart = $1.start else {return false}
                return leftScheduleStart < rightScheduleStart
            })
            return schedules
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: 선택된 스케쥴을 Core Data에서 삭제하는 함수
    @discardableResult
    private func deleteSchedule(_ at: Schedule) -> Bool{
        context.delete(at)
        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
