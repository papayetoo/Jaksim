//
//  ScheduleSearchViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/04/12.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxDataSources
import CoreData


class ScheduleSearchViewController: UIViewController {
    
    typealias Schedules = [Schedule]
    typealias ScheduleSectionModel = SectionModel<String, Schedule>
    typealias ScheduleDataSource = RxTableViewSectionedReloadDataSource<ScheduleSectionModel>
    
    var disposeBag = DisposeBag()
    
    let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let searchResultTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let context = PersistantManager.shared.context
    var searchedSchedules = Schedules()
    let schedulesRelay: BehaviorRelay<[ScheduleSectionModel]> = BehaviorRelay(value: [])

    private let dateFormatter = DateFormatter()
    
    private var scheduleDatasource: ScheduleDataSource {
        let configureCell: (TableViewSectionedDataSource<ScheduleSectionModel>, UITableView, IndexPath, Schedule) -> UITableViewCell = { (source, tableView, indexPath, schedule) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.cellId, for: indexPath) as? ScheduleCell else { return UITableViewCell() }
            cell.schedule = schedule
            return cell
        }
        let dataSource = ScheduleDataSource(configureCell: configureCell)
        dataSource.titleForHeaderInSection = {dataSource, index in
            return dataSource.sectionModels[index].model
        }
        return dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.cellId)
        view.backgroundColor = .systemBackground
        setSubviews()
        
//        schedulesRelay
//            .bind(to: searchResultTableView.rx.items(cellIdentifier: ScheduleCell.cellId, cellType: ScheduleCell.self)) { (index, schedule, cell) in
//                cell.titleLabel.text = schedule.title
//                cell.contentsTextView.text = schedule.contents
//            }
//            .disposed(by: disposeBag)
        schedulesRelay
            .bind(to: searchResultTableView.rx.items(dataSource: scheduleDatasource))
            .disposed(by: disposeBag)
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        searchTextField.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] in
                guard let strongSelf = self else {return}
                let inputString = $0 as String
                let request: NSFetchRequest<Schedule> = Schedule.fetchRequest()
                request.predicate = NSPredicate(format: "title CONTAINS %@", inputString)
                do {
                    let schedules = try strongSelf.context.fetch(request) as Schedules
                    var schedulesByDate: [String: Schedules] = [:]
                    for schedule in schedules {
                        let date = strongSelf.dateFormatter.string(from: Date.init(timeIntervalSince1970: schedule.startEpoch))
                        if schedulesByDate[date] == nil {
                            schedulesByDate[date] = [schedule]
                        } else {
                            schedulesByDate[date]?.append(schedule)
                        }
                    }
                    let sectionModels = schedulesByDate.map({date, dateSchedules in
                        return ScheduleSectionModel(model: date, items: dateSchedules)
                    })
                    strongSelf.schedulesRelay.accept(sectionModels)
                } catch {
                    print("Get schedule Error \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: 키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("view touches began")
        searchTextField.endEditing(true)
    }
    
    func setSubviews() {
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(50)
        }
        
        view.addSubview(searchResultTableView)
        searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    

}

