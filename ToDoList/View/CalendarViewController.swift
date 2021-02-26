//
//  CalendarViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/15.
//

import UIKit
import FSCalendar
import SnapKit
import RxCocoa
import RxSwift

class CalendarViewController: UIViewController {
    
    private let calendarView: FSCalendar = {
        let view = FSCalendar(frame: .init(x: 0, y: 0, width: 320, height: 320))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel: ScheduleViewModel = ScheduleViewModel()
    private let selectedDatesSubject: BehaviorRelay<[Date]> = BehaviorRelay(value: [])
    private let disposebag = DisposeBag()
    private var selectedDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("CalendarViewController begin")
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        view.addSubview(calendarView)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.locale = Locale(identifier: "ko_kr")
        calendarView.allowsMultipleSelection = true
        calendarView.swipeToChooseGesture.isEnabled = true
        
        selectedDatesSubject
            .bind(to: viewModel.selectedDatesRelay)
            .disposed(by: disposebag)
        
        calendarView.appearance.weekdayTextColor = .black
        calendarView.appearance.headerTitleColor = .black
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.selectionColor = .systemGreen
        
        calendarView.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        calendarView.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(300)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        return calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
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
        self.selectedDates.append(date)
    }
}
