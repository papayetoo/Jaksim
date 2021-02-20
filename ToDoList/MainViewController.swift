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
    
    var today: Date = Date()
    let sevenDaysComponent: DateComponents = DateComponents(day: 7)
    private let gregorianCalender: Calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "HH:mm"
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
        self.view.addSubview(weatherImgView)
        
        
        self.timeLineTbView.addSubview(self.addButton)
        self.addButton.addTarget(self, action: #selector(touchAddButton(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            weatherImgView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            weatherImgView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            weatherImgView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            weatherImgView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 70),
            self.addButton.widthAnchor.constraint(equalToConstant: 50),
            self.addButton.heightAnchor.constraint(equalToConstant: 50),
            self.addButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80),
            self.addButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
        ])
        self.setNavigationAppearance()
        
        
        
        guard let endDate = self.gregorianCalender.date(byAdding: sevenDaysComponent, to: today) else {return}
        var transformedDates: [String] = []
        var currentDate = today
        var count = 0
        while count < 7 {
            transformedDates.append(dateFormatter.string(from: currentDate))
            currentDate += 24 * 60 * 60
            count += 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        getSchedule()
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
    
    func getSchedule() {
        let context = PersistantManager.shared.context
//        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else {return}
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
        let letfPredicate = NSPredicate(format: "start >= %@", self.today.startOfDay.toLocalTime() as NSDate)
        let rightPredicate = NSPredicate(format: "start <= %@", self.today.endOfDay.toLocalTime() as NSDate)
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
        moveAddButton()
    }
    
    func moveAddButton() {
        let originPos = self.addButton.center
        UIView.animate(withDuration: 0.3, animations: {
            self.addButton.center = CGPoint(x: self.view.center.x, y: originPos.y)
        }, completion: { _ in
            print("move circle completed")
            let scheduleAddVC = ScheduleAddViewController()
            scheduleAddVC.completionHandler = { [weak self] in
                print("scheduleAddVC dismissed")
                self?.getSchedule()
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

extension MainViewController: UITableViewDataSource {
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
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}
