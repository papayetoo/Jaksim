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
        textField.placeholder = "일정 제목이나 내용 일부를 입력해주세요."
        return textField
    }()
    
    let searchResultTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.cellId)
        return tableView
    }()
    
    var viewModel: ScheduleSearchViewModel? = nil
    
    let context = PersistantManager.shared.context
    var searchedSchedules = Schedules()

    private let dateFormatter = DateFormatter()
    
    private var scheduleDatasource: ScheduleDataSource {
        let configureCell: (TableViewSectionedDataSource<ScheduleSectionModel>, UITableView, IndexPath, Schedule) -> UITableViewCell = { (source, tableView, indexPath, schedule) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.cellId, for: indexPath) as? ScheduleCell else { return UITableViewCell() }
            cell.schedule = schedule
            cell.scheduleEditDelegate = self
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
        view.backgroundColor = .systemBackground
        searchTextField.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSearchResultTableView))
        searchResultTableView.addGestureRecognizer(tapGestureRecognizer)
        setSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel = ScheduleSearchViewModel()
        guard let strongViewModel = viewModel else {return}
        searchResultTableView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
            guard let strongSelf = self,
                  let cell = strongSelf.searchResultTableView.cellForRow(at: indexPath) as? ScheduleCell  else {return}
            strongSelf.view.endEditing(true)
            cell.contentsTextView.isHidden = !cell.contentsTextView.isHidden
            strongSelf.searchResultTableView.beginUpdates()
            strongSelf.searchResultTableView.endUpdates()
            })
            .disposed(by: disposeBag)
        strongViewModel.resultSchedulesRelay
            .bind(to: searchResultTableView
                    .rx
                    .items(dataSource: scheduleDatasource))
            .disposed(by: disposeBag)
        searchResultTableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        bindUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    // MARK: 키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
    
    func bindUI() {
        guard let strongViewModel = viewModel else {return}
        searchTextField.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(strongViewModel.searchTextFieldRelay)
            .disposed(by: disposeBag)
    }
}

extension ScheduleSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? ScheduleCell else {return 100}
        if cell.contentsTextView.isHidden {
            return 100
        } else {
            return 90 + cell.contentsTextView.contentSize.height
        }
    }
}

extension ScheduleSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension ScheduleSearchViewController: ScheduleCellDelegate {
    func edit(_ schedule: Schedule) {
        let editViewController = ScheduleViewController()
        editViewController
            .viewModel
            .editableRelay
            .accept(true)
        editViewController
            .viewModel
            .scheduleRelay
            .accept(schedule)
        editViewController.modalPresentationStyle = .fullScreen
        present(editViewController, animated: true, completion: nil)
        editViewController.completionHandler = { [weak self] in
            print("scheduleAddVC dismissed")
            self?.searchResultTableView.reloadData()
        }
    }
}

extension ScheduleSearchViewController {
    @objc
    func didTapSearchResultTableView(_ sender: UITableView) -> Void {
        searchTextField.resignFirstResponder()
    }
}
