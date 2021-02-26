//
//  ViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/13.
//

import UIKit
import SnapKit
import FSCalendar
import CoreData
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    
    private let toDoCalendar: ToDoCalendar = {
        let view = ToDoCalendar(frame: .init(x: 0, y: 0, width: 100, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scheduleTbView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: 일정 추가 버튼
    // 원 모양 검은 배경 흰 더하기 이미지
    private let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.backgroundColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25
        return button
    }()
    
    // MARK: 선택된 날
    private var selectedDate = Date()
    // MARK: 1주 간의 date를 표시하기 위한 변수
    private var dates: [Date]?
    
    private var selectedIndexPath: IndexPath?
    
    private let scheduleTableCellId = "ScheduleCell"
    private let calendarCellId = "DayCell"
    
    private let viewModel: ScheduleViewModel = ScheduleViewModel()
    private var eventCount: [Int] = []
    private let disposeBag = DisposeBag()
    // MARK: 스케쥴 표시하기 위한 데이터
    var schedules: [Schedule]? {
        didSet {
            self.scheduleTbView.reloadData()
        }
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 스케쥴 테이블 dataSource, delegate, cell 등록
        // 일정 추가 버튼 추가
        configureSubviews()
        guard let today = toDoCalendar.today else {return}
        viewModel.currentMonthRelay.accept(toDoCalendar.currentPage.startOfDay)
        // 선택된 날들에 대한 스케쥴을 가져옴.
        viewModel.selectedDatesRelay.accept([today])
                                             
        viewModel.schedulesRelay
            .filter({$0.count == 1})
            .flatMap({ Observable.from($0)})
            .subscribe(onNext: {[weak self] updatedSchedules in self?.schedules = updatedSchedules})
            .disposed(by: disposeBag)
        
        viewModel.schedulesRelay
            .filter({$0.count == 1})
            .flatMap({ Observable.from($0)})
            .bind(to: scheduleTbView.rx.items(cellIdentifier: scheduleTableCellId, cellType: ScheduleCell.self)) {
                (index: Int, schedule: Schedule, cell: ScheduleCell) in
                cell.selectionStyle = .none
                cell.layer.backgroundColor = UIColor.clear.cgColor
                cell.backgroundColor = .clear
                cell.schedule = schedule
            }.disposed(by: disposeBag)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
//        getSchedule(of: selectedDate)
    }
    
    // MARK: toDoCalendar, ScheduleTbView, addButton 설정
    func configureSubviews() {
        // toDoCalendar 설정
        view.addSubview(toDoCalendar)
        toDoCalendar.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(200)
        }
        toDoCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: calendarCellId)
        toDoCalendar.scope = .month
        toDoCalendar.layoutMargins = .zero
        toDoCalendar.scrollDirection = .horizontal
        toDoCalendar.backgroundColor = .white
        toDoCalendar.adjustsBoundingRectWhenChangingMonths = true
        toDoCalendar.allowsMultipleSelection = true
        toDoCalendar.dataSource = self
        toDoCalendar.delegate = self
        
        // scheduleTbView 설정
        view.addSubview(scheduleTbView)
//        scheduleTbView.dataSource = self
//        scheduleTbView.delegate = self
        scheduleTbView.register(ScheduleCell.self, forCellReuseIdentifier: scheduleTableCellId)
        scheduleTbView.snp.makeConstraints{
            $0.top.equalTo(toDoCalendar.snp.bottom).offset(10)
            $0.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        scheduleTbView.addSubview(addButton)
        
        
        
        setNavigationAppearance()
        // AddButton 설정
        addButton.snp.makeConstraints{
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-100)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-80)
            $0.width.height.equalTo(50)
        }
        addButton.addTarget(self, action: #selector(touchAddButton(_:)), for: .touchUpInside)
    }
    
    // MARK: 네비게이션바 모양을 투명하게 바꿈
    func setNavigationAppearance() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationAppearance
    }
    
    // MARK: CoreData 실험 위한 데이터 추가용
    func addSchedule() {
        let context = PersistantManager.shared.context
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else {return}
        do {
            let schedule = NSManagedObject(entity: entity, insertInto: context)
            let title = "test"
            let start = Date()
            let end = start + 60 * 60
            let alarm = false
            schedule.setValue(title, forKey: "title")
            schedule.setValue(start, forKey: "start")
            schedule.setValue(end, forKey: "end")
            schedule.setValue(alarm, forKey: "alarm")
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getSchedule(of date: Date) {
        let context = PersistantManager.shared.context
//        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else {return}
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
        let letfPredicate = NSPredicate(format: "start >= %@", date.startOfDay.toLocalTime() as NSDate)
        let rightPredicate = NSPredicate(format: "start <= %@",date.endOfDay.toLocalTime() as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [letfPredicate, rightPredicate])
        do {
            guard let schedules = try context.fetch(request) as? [Schedule] else {return}
            self.schedules = schedules
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func touchAddButton(_ sender: UIButton){
        print(sender)
        presentScheduleAddView()
    }
    
    func presentScheduleAddView() {
        let originPos = self.addButton.center
        UIView.animate(withDuration: 0.3, animations: {
            self.addButton.center = CGPoint(x: self.view.center.x, y: originPos.y)
        }, completion: { _ in
            print("move circle completed")
            let scheduleAddVC = ScheduleAddViewController()
            scheduleAddVC.selectedDate = self.selectedDate
            scheduleAddVC.completionHandler = { [weak self] in
                print("scheduleAddVC dismissed")
                self?.getSchedule(of: self?.selectedDate ?? Date())
                self?.scheduleTbView.reloadData()
            }
            self.present(scheduleAddVC, animated: true, completion: {
                UIView.animate(withDuration: 0.3, animations: { 
                self.addButton.center = CGPoint(x: originPos.x, y: originPos.y)
                })
            })
        })
    }
    
    func appendDates(completion: @escaping (([Date])-> Void)) {
        guard var dates = self.dates, var lastDate = dates.last?.endOfDay else {return}
        lastDate += 1
        let rightSideWeek = stride(from: lastDate.startOfWeek, to: lastDate.endOfWeek, by: 24 * 60 * 60).map {$0}
        completion(rightSideWeek)
    }
    
}

extension MainViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.schedules?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleTableCellId, for: indexPath) as? ScheduleCell else {return UITableViewCell()}
//        cell.selectionStyle = .none
//        cell.layer.backgroundColor = UIColor.clear.cgColor
//        cell.backgroundColor = .clear
//        cell.schedule = schedules?[indexPath.row]
////        cell.schduleViewModel?.scheduleSubject.onNext(mySchedules?[indexPath.row])
//        return cell
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let selectedIndexPath = selectedIndexPath else {return 100}
        if selectedIndexPath == indexPath {
            return 300
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleTableCellId, for: indexPath) as? ScheduleCell else {return}
        cell.contentsTextView.text = cell.schedule?.contents
        selectedIndexPath = indexPath
        self.scheduleTbView.beginUpdates()
        self.scheduleTbView.endUpdates()
    }
    

    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndexPath = nil
    }
    
    
}

extension MainViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: calendarCellId, for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        switch date.weekDay{
        case 7:
            return .systemBlue
        case 2...6:
            return .black
        default:
            return .systemPink
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.selectedDatesRelay.accept(calendar.selectedDates)
//        if calendar.selectedDates.count > 1 {
//            return
//        } else {
//            getSchedule(of: date)
//        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
        self.view.layoutIfNeeded()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.currentMonthRelay.accept(toDoCalendar.currentPage.startOfDay)
    }
}



//extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.dates?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekDateCell", for: indexPath) as? WeekDateCell, let dateForItemAt = self.dates?[indexPath.item] else {return UICollectionViewCell()}
//        cell.date = dateForItemAt
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? WeekDateCell, let selectedDate = cell.date else {return}
//        self.selectedDate = selectedDate
//        print("touched", selectedDate)
//        getSchedule(of: self.selectedDate)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.frame.width / 7
//        let height = CGFloat(50)
//        return CGSize(width: width, height: height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let position = scrollView.contentOffset.x
//        guard let visibleCells = self.weekCollectionView.visibleCells as? [WeekDateCell] else {return}
//
//        if position > self.weekCollectionView.contentSize.width - 100 - scrollView.frame.width {
//            print("right side end")
//            self.appendDates { [weak self] anotherWeek in
//                self?.dates?.append(contentsOf: anotherWeek)
//                DispatchQueue.main.async {
//                    self?.weekCollectionView.reloadData()
//                }
//            }
//        }
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        guard let collectionView = scrollView as? UICollectionView, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
//        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
//
//        var offset = targetContentOffset.pointee
//        var idx = round((offset.x + collectionView.contentInset.left) / cellWidth)
//        var roundedIndex = round(idx)
//
//        offset = CGPoint(x: roundedIndex * 7 * cellWidth, y: 0)
//        targetContentOffset.pointee = offset
//    }
//
//
//}
