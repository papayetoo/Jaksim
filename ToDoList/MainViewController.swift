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
    
    
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var timeLineTbView: UITableView!

    let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.backgroundColor = UIColor.systemPurple.cgColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    let weatherImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "rainy")
        return imageView
    }()
    
    let today: Date = Date()
    let sevenDaysComponent: DateComponents = DateComponents(day: 7)
    private let gregorianCalender: Calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd"
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
        self.addButton.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        NSLayoutConstraint.activate([
            weatherImgView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            weatherImgView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            weatherImgView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            weatherImgView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
            addButton.bottomAnchor.constraint(equalTo: self.timeLineTbView.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addButton.trailingAnchor.constraint(equalTo: self.timeLineTbView.safeAreaLayoutGuide.trailingAnchor, constant: -50)
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
        self.setDateBtns(DatesString: transformedDates)
        self.dateStackView.distribution = .fillEqually
        getSchedule()
        
        
    }
    
    func setNavigationAppearance() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationAppearance
    }
    
    func setDateBtns(DatesString: [String]) {
        self.dateButtons = DatesString.map {
            let dateButton = UIButton(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
            dateButton.layer.shadowColor = UIColor.black.cgColor
            dateButton.layer.shadowOffset = CGSize(width: 1, height: 1)
            dateButton.layer.shadowRadius = 2.5
            dateButton.layer.shadowPath = UIBezierPath(arcCenter: dateButton.center, radius: 25, startAngle: 0, endAngle: 4 * .pi, clockwise: true).cgPath
            dateButton.layer.shadowOpacity = 0.3
            dateButton.layer.cornerRadius = 25
            dateButton.layer.backgroundColor = UIColor.white.cgColor
            dateButton.setTitleColor(.black, for: .normal)
            dateButton.setTitleColor(.white, for: .selected)
            dateButton.setTitle($0, for: .normal)
            dateButton.isUserInteractionEnabled = true
            dateButton.addTarget(self, action: #selector(dateButtonTouched(_:)), for: .touchUpInside)
            self.dateStackView.addArrangedSubview(dateButton)
            return dateButton
        }
        self.dateButtons?[0].isSelected = true
    }
    
    @objc func dateButtonTouched(_ sender: UIButton){
        _ = self.dateButtons?.map {
            if $0 == sender {
                $0.isSelected = true
                $0.layer.backgroundColor = UIColor.black.cgColor
            }
            else {
                $0.isSelected = false
                $0.layer.backgroundColor = UIColor.white.cgColor
            }
        }
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
        do {
            guard let schedules = try context.fetch(request) as? [Schedule] else {return}
            mySchedules = schedules
        } catch {
            print(error.localizedDescription)
        }
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
//        cell.schedule = mySchedules?[indexPath.row]
        cell.schduleViewModel?.scheduleSubject.onNext(mySchedules?[indexPath.row])
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}
