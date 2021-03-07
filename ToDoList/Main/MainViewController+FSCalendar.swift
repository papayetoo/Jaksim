//
//  MainViewController+FSCalendar.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/03.
//

import FSCalendar
import SnapKit

extension MainViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance  {
    
    // MARK: 이벤트 수 받아오는 로직에 대해서 고민이 필요함.
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let startOfDay = date.startOfDay.toLocalTime()
//        let schedules = self.getSchedule(of: startOfDay)
//        return schedules?.count ?? 0
        var schedules = 0
        viewModel.eventForDateInputRelay.accept(startOfDay)
        viewModel.eventForDateOutputRelay
            .subscribe(onNext: {
                schedules = $0
            }).disposed(by: disposeBag)
        return schedules
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
        self.viewModel.selectedDatesRelay.accept(calendar.selectedDates)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints({ (make) in
            make.height.equalTo(bounds.height)
        })
        view.layoutIfNeeded()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.currentMonthRelay.accept(self.toDoCalendar.currentPage.startOfDay)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [.black]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return [.systemYellow]
    }
}

