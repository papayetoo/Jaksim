//
//  WeekDayCellViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/22.
//

import Foundation
import RxSwift
import RxCocoa

struct MainCellViewModel {
    
    let selectedDateSubject = BehaviorSubject<Date>(value: Date())
    let colorsSubject = BehaviorSubject<[UIColor]>(value: [])
    let radiusSubject = BehaviorSubject<[CGFloat]>(value: [])
    let weekDaysSubject = BehaviorSubject<[Date]>(value: [])
    let weekDaysStringSubject = BehaviorSubject<[String]>(value: [])
    
    
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "d"
        return formatter
    }()
    
    init() {
        self.setWeekDaySubject()
    }
    
    func setWeekDaySubject() {
        do {
            let selectedDate = try selectedDateSubject.value()
            let startOfWeek = selectedDate.startOfWeek.toLocalTime()
            let endOfWeek = selectedDate.endOfWeek.toLocalTime()
            let weekStride = stride(from: startOfWeek, to: endOfWeek, by: 24 * 60 * 60)
            let colors: [UIColor] = weekStride.map {
                if $0.day == selectedDate.day {
                    return .systemPink
                } else {
                    return .white
                }
            }
            let radius: [CGFloat] = weekStride.map {
                if $0.day == selectedDate.day {
                    return CGFloat(25)
                } else {
                    return CGFloat(0)
                }
            }
            let weekDays = weekStride.map {$0}
            let weekDayStrings = weekStride.map { self.dateFormatter.string(from: $0)}
            colorsSubject.onNext(colors)
            radiusSubject.onNext(radius)
            weekDaysSubject.onNext(weekDays)
            weekDaysStringSubject.onNext(weekDayStrings)
        } catch {
            print(error)
        }
    }
    
    func getResultObservable() -> Observable<(Date, [UIColor], [CGFloat], [Date], [String])> {
        return Observable.combineLatest(self.selectedDateSubject, self.colorsSubject, self.radiusSubject, self.weekDaysSubject, self.weekDaysStringSubject)
    }
}
