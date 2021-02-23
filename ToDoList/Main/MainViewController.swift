//
//  ViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/13.
//

import UIKit
import RxSwift
import CoreData

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var weekCollectionView: UICollectionView!
    @IBOutlet weak var timeLineTbView: UITableView!

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
    
    private let dayOfTheWeekCollectionView: DayOfTheWeekCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let view = DayOfTheWeekCollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: 스케쥴 표시하기 위한 데이터
    var mySchedules: [Schedule]? {
        didSet {
            print(mySchedules)
            self.timeLineTbView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "\(selectedDate.month)월"
        // 스케쥴 테이블 dataSource, delegate, cell 등록
        // 일정 추가 버튼 추가
        self.view.addSubview(self.dayOfTheWeekCollectionView)
        self.timeLineTbView.dataSource = self
        self.timeLineTbView.delegate = self
        self.timeLineTbView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        self.timeLineTbView.addSubview(self.addButton)
        self.addButton.addTarget(self, action: #selector(touchAddButton(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            self.dayOfTheWeekCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.dayOfTheWeekCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.dayOfTheWeekCollectionView.bottomAnchor.constraint(equalTo: self.weekCollectionView.topAnchor),
            self.dayOfTheWeekCollectionView.heightAnchor.constraint(equalToConstant: 50),
            self.addButton.widthAnchor.constraint(equalToConstant: 50),
            self.addButton.heightAnchor.constraint(equalToConstant: 50),
            self.addButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80),
            self.addButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
        ])
        
        self.weekCollectionView.dataSource = self
        self.weekCollectionView.delegate = self
        self.dates = stride(from: selectedDate.startOfWeek.toLocalTime(), to: selectedDate.endOfWeek.toLocalTime(), by: 24 * 60 * 60)
            .map({$0})
        self.weekCollectionView.reloadData()

        self.setNavigationAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        getSchedule(of: selectedDate)
    }
    
    // MARK: 네비게이션바 모양을 투명하게 바꿈
    func setNavigationAppearance() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationAppearance
    }
    
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
            mySchedules = schedules
            schedules.map {
                print($0.title, $0.start)
            }
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
                self?.timeLineTbView.reloadData()
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

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mySchedules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.backgroundColor = .clear
        cell.schedule = mySchedules?[indexPath.row]
//        cell.schduleViewModel?.scheduleSubject.onNext(mySchedules?[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dates?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekDateCell", for: indexPath) as? WeekDateCell, let dateForItemAt = self.dates?[indexPath.item] else {return UICollectionViewCell()}
        cell.date = dateForItemAt
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? WeekDateCell, let selectedDate = cell.date else {return}
        self.selectedDate = selectedDate
        print("touched", selectedDate)
        getSchedule(of: self.selectedDate)
    }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        let position = scrollView.contentOffset.x
        print(position)
        print("begin")
        print(scrollView.frame)
        guard let visibleCells = self.weekCollectionView.visibleCells as? [WeekDateCell] else {return}
        
        if position > self.weekCollectionView.contentSize.width - 100 - scrollView.frame.width {
            print("right side end")
            self.appendDates { [weak self] anotherWeek in
                self?.dates?.append(contentsOf: anotherWeek)
                DispatchQueue.main.async {
                    self?.weekCollectionView.reloadData()
                }
            }
        }
    }
    
    
}
