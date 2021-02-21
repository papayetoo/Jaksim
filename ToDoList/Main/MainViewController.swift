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
    
    // MARK: 날씨 관련된 배경화면
    private let weatherImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "rainy")
        return imageView
    }()
    
    var selectedDate: Date = Date()
    var weekDate: [Date] = [] {
        didSet {
            self.weekCollectionView.reloadData()
        }
    }
    let sevenDaysComponent: DateComponents = DateComponents(day: 7)
    private let gregorianCalender: Calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var dateButtons: [UIButton]?
    
    var mySchedules: [Schedule]? {
        didSet {
            self.timeLineTbView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.timeLineTbView.dataSource = self
        self.timeLineTbView.delegate = self
        self.timeLineTbView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        
        self.weekCollectionView.dataSource = self
        self.weekCollectionView.delegate = self
        guard let flowLayout = self.weekCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        
        
        self.timeLineTbView.addSubview(self.addButton)
        self.addButton.addTarget(self, action: #selector(touchAddButton(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            self.addButton.widthAnchor.constraint(equalToConstant: 50),
            self.addButton.heightAnchor.constraint(equalToConstant: 50),
            self.addButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80),
            self.addButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
        ])
        self.setNavigationAppearance()
        
        let startOfWeek = selectedDate.startOfWeek.startOfDay.toLocalTime()
        let endOfWeek = selectedDate.endOfWeek.startOfDay.toLocalTime()
        
        for date in stride(from: startOfWeek, to: endOfWeek, by: 24 * 60 * 60){
            self.weekDate.append(date)
        }
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

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          guard self.weekDate.count > 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath) as? WeekCell else {return UICollectionViewCell()}
            let date = self.weekDate[indexPath.item]
            cell.date = date
            cell.isToday = date == self.selectedDate.startOfDay.toLocalTime()
            return cell
        }
}
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WeekDayHeader", for: indexPath)
//            headerView.backgroundColor = .systemPurple
//            headerView.
//            return headerView
//        default:
//            assert(false, "에러 발생")
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: 100, height: 30)
//    }
    

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cells = collectionView.visibleCells as? [WeekCell] else {return}
        let selectedIndex = indexPath
        _ = cells.map { [weak self] weekCell in
            if collectionView.indexPath(for: weekCell) != selectedIndex {
                weekCell.isToday = false
            } else {
                weekCell.isToday = true
                selectedDate = weekCell.date ?? Date()
                self?.getSchedule(of: selectedDate)
                self?.timeLineTbView.reloadData()
            }
        }
    }
    
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 7 - 0.3
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
