//
//  ScheduleSearchViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/04/13.
//

import RxCocoa
import RxSwift
import RxDataSources
import CoreData

class ScheduleSearchViewModel {
    
    private typealias Schedules = [Schedule]
    typealias ScheduleSectionModel = SectionModel<String, Schedule>
    typealias ScheduleDataSource = RxTableViewSectionedReloadDataSource<ScheduleSectionModel>
    
    let searchTextFieldRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    let resultSchedulesRelay: BehaviorRelay<[ScheduleSectionModel]> = BehaviorRelay(value: [])
    
    private let context = PersistantManager.shared.context
    private let dateFormatter = DateFormatter()

    private var disposeBag = DisposeBag()
    
    init() {
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        searchTextFieldRelay.map { [weak self] queryText -> [ScheduleSectionModel] in
            print("In the SearchScheduleViewModel: \(queryText)")
            guard let strongSelf = self else {return []}
            let request: NSFetchRequest<Schedule> = Schedule.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS %@ || contents CONTAINS %@", queryText, queryText)
            do {
                let schedules = try strongSelf.context.fetch(request) as Schedules
                var schedulesByDate: [String: Schedules] = [:]
                for schedule in schedules {
                    print(schedule.title)
                    let date = strongSelf.dateFormatter.string(from: Date.init(timeIntervalSince1970: schedule.startEpoch))
                    if schedulesByDate[date] == nil {
                        schedulesByDate[date] = [schedule]
                    } else {
                        schedulesByDate[date]?.append(schedule)
                    }
                }
                let sectionModels = schedulesByDate.map( {date, dateSchedules in
                    return ScheduleSectionModel(model: date, items: dateSchedules)
                })
                return sectionModels
            } catch {
                print("CoreData Search Error \(error.localizedDescription)")
                return []
            }
        }
        .bind(to: resultSchedulesRelay)
        .disposed(by: disposeBag)
    }
}
