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
    private var eventAtDate: [Date:Int] = [:]
    private var numberOfSectionInSchduleTable: Int = 0
    // MARK: 스케쥴 표시하기 위한 데이터
//    var schedules: [Schedule]? {
//        didSet {
//            self.scheduleTbView.reloadData()
//        }
//    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 스케쥴 테이블 dataSource, delegate, cell 등록
        // 일정 추가 버튼 추가
        configureSubviews()
        view.backgroundColor = .systemBlue
        guard let today = toDoCalendar.today else {return}
        viewModel.currentMonthRelay.accept(toDoCalendar.currentPage.startOfDay)
        
        // 폰트 체크 하기
//        UIFont.familyNames.sorted().forEach{ familyName in
//           print("*** \(familyName) ***")
//           UIFont.fontNames(forFamilyName: familyName).forEach { fontName in
//               print("\(fontName)")
//           }
//           print("---------------------")
//        }

        
        // 선택된 날들에 대한 스케쥴을 가져옴.
        viewModel.selectedDatesRelay.accept([today])
                              
        viewModel.schedulesRelay
            .map({$0.count})
            .subscribe(onNext:{ [weak self] count in
                self?.numberOfSectionInSchduleTable = count
            })
        
     
        // UITableView의 didSelectRowAt 관련된 RxSwift 함수
        scheduleTbView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let cell = self?.scheduleTbView.cellForRow(at: indexPath) as? ScheduleCell else {return}
                self?.viewModel.selectedScheduleRelay.accept(cell.schedule)
                cell.contentsTextView.isHidden = !cell.contentsTextView.isHidden
                if cell.contentsTextView.isHidden {
                    self?.selectedIndexPath = nil
                } else{
                    self?.selectedIndexPath = indexPath
                }
                self?.scheduleTbView.beginUpdates()
                self?.scheduleTbView.endUpdates()
            }, onCompleted: {
                print("cell touched")
            })
            .disposed(by: disposeBag)
        
        viewModel.eventsAtDateSubject
            .subscribe(onNext:{ [weak self] fetchedSchedulesCount in
                print(fetchedSchedulesCount)
                self?.eventAtDate = fetchedSchedulesCount})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // MARK: Waring 발생 UITableViewDelegate의 cellForRowAt 함수
        // 해결방법 : viewDidLoad -> viewDidApper로 이동
        // Git에도 에러 Report 되어 있음
        viewModel.schedulesRelay
//            .filter({$0.count == 1 && $0[0].count > 0})
            .flatMap({ Observable.from($0)})
            .bind(to: scheduleTbView.rx.items(cellIdentifier: ScheduleCell.cellId, cellType: ScheduleCell.self)) {
                (index: Int, schedule: Schedule, cell: ScheduleCell) in
                cell.selectionStyle = .none
                cell.contentsTextView.isHidden = true
                cell.schedule = schedule
            }.disposed(by: disposeBag)
    }
    
    // MARK: toDoCalendar, ScheduleTbView, addButton 설정
    func configureSubviews() {
        // toDoCalendar 설정
        view.addSubview(toDoCalendar)
        toDoCalendar.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(300)
        }
        toDoCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: calendarCellId)
        toDoCalendar.scope = .month
        toDoCalendar.layoutMargins = .zero
        toDoCalendar.scrollDirection = .horizontal
        toDoCalendar.backgroundColor = .white
//        toDoCalendar.adjustsBoundingRectWhenChangingMonths = true
        toDoCalendar.needsAdjustingViewFrame = true
//        toDoCalendar.appearance.headerTitleFont = UIFont(name: "BMEuljiro10yearslaterOTF", size: 20)
        
        toDoCalendar.appearance.headerTitleFont = UIFont(name: "wemakepriceot-bold", size: 20)
        toDoCalendar.appearance.weekdayFont = UIFont(name: "wemakepriceot-semibold", size: 15)
        toDoCalendar.appearance.titleFont = UIFont(name: "wemakepriceot-regular", size: 12)
        toDoCalendar.dataSource = self
        toDoCalendar.placeholderType = .none
        toDoCalendar.delegate = self
        let scopeGesture = UIPanGestureRecognizer(target: toDoCalendar, action: #selector(toDoCalendar.handleScopeGesture(_:)))
        toDoCalendar.addGestureRecognizer(scopeGesture)
        
        
        // scheduleTbView 설정
        view.addSubview(scheduleTbView)

        scheduleTbView.delegate = self
        scheduleTbView.snp.makeConstraints{
            $0.top.lessThanOrEqualTo(toDoCalendar.snp.bottom)
            $0.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        scheduleTbView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.cellId)
        
        
        // NavigationBar 설정
        setNavigationAppearance()
        // AddButton 설정
        view.addSubview(addButton)
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
        let rightPredicate = NSPredicate(format : "start <= %@",date.endOfDay.toLocalTime() as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [letfPredicate, rightPredicate])
        do {
            guard let schedules = try context.fetch(request) as? [Schedule] else {return}
//            self.schedules = schedules
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func touchAddButton(_ sender: UIButton){
        print(sender)
        presentScheduleAddView()
    }
    // MARK: 일정 추가 버튼 클릭시 일정 추가 버튼 팝업
    func presentScheduleAddView() {
        guard let selectedDate = toDoCalendar.selectedDate else {return}
        let originPos = self.addButton.center
        UIView.animate(withDuration: 0.3, animations: {
            self.addButton.center = CGPoint(x: self.view.center.x, y: originPos.y)
        }, completion: { [weak self] _ in
            print("move circle completed")
            let scheduleAddVC = ScheduleAddViewController()
            print("presentScheduleAddView \(selectedDate.toLocalTime())")
            scheduleAddVC.viewModel.startTimeRelay.accept(selectedDate.toLocalTime())
            scheduleAddVC.completionHandler = { [weak self] in
                print("scheduleAddVC dismissed")
                self?.viewModel.selectedDatesRelay.accept([selectedDate])
                self?.scheduleTbView.reloadData()
            }
            self?.present(scheduleAddVC, animated: true, completion: {
                UIView.animate(withDuration: 0.3, animations: { 
                self?.addButton.center = CGPoint(x: originPos.x, y: originPos.y)
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? ScheduleCell else {return nil}
        viewModel.selectedScheduleRelay.accept(cell.schedule)
        let action = UIContextualAction(style: .destructive, title: "삭제"){
            [weak self] (_, _, completionHandler) in
            // 삭제 액션이 발생했음을 viewModel에 알림
            self?.viewModel.deletedActionRelay
                .accept(())
//            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        action.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          guard let selectedIndexPath = selectedIndexPath else {return 100}
          if selectedIndexPath == indexPath {
              return 300
          } else {
              return 100
          }
    }
}

extension MainViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance  {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let startOfDay = date.startOfDay.toLocalTime()
        print(startOfDay, eventAtDate[startOfDay] ?? 0)
        return eventAtDate[startOfDay] ?? 0
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
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints({ (make) in
            make.height.equalTo(bounds.height)
        })
        view.layoutIfNeeded()
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("currentPage Changed")
        viewModel.currentMonthRelay.accept(toDoCalendar.currentPage.startOfDay)
    }
}
