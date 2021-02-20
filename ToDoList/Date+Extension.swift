//
//  Date+extension.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/15.
//

import Foundation

extension Date {
    
    var day: Int {
        return Calendar(identifier: .gregorian).component(.day, from: self)
    }
    
    var month: Int {
        return Calendar(identifier: .gregorian).component(.month, from: self)
    }
    
    var weekDay: Int {
        return Calendar(identifier: .gregorian).component(.weekday, from: self)
    }
    
    var weeksOfMonth: Int {
        // MARK: 한 달에 몇 주인지 알려주는 변수 (일 월 화 수 목 금 토 ) 순서
        return Calendar(identifier: .gregorian).component(.weekOfMonth, from: self.endOfMonth)
    }
    
    var year: Int {
        return Calendar(identifier: .gregorian).component(.year, from: self)
    }
    
    var startOfMonth: Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: self)
        let startDate = Calendar(identifier: .gregorian).date(from: components)
        return (startDate ?? self).toLocalTime()
    }
    
    var endOfMonth: Date {
        let components = DateComponents(month: 1, day: -1)
        let endDate = Calendar(identifier: .gregorian).date(byAdding: components, to: self.startOfMonth)
        return (endDate ?? self)
    }
    
    var startOfDay: Date {
        let components = DateComponents(year: self.year, month: self.month, day: self.day, hour: 0, minute: 0, second: 0)
        let date = Calendar(identifier: .gregorian).date(from: components)
        return (date ?? self)
    }
    
    var endOfDay: Date{
        let components = DateComponents(hour: 24, second: -1)
        let date = Calendar(identifier: .gregorian).date(byAdding: components, to: self.startOfDay)
        return (date ?? self)
    }
    
    var datesOfMonth: [[Date?]] {
        var dates: [[Date?]] = []
        let numOfMonthWeeks = self.weeksOfMonth
        let currentMonth = self.month
        var start = self.startOfMonth
        var weekCounter = 0
        while weekCounter < numOfMonthWeeks {
            var oneWeek = Array<Date?>(repeating: nil, count: start.weekDay - 1)
            var count = start.weekDay - 1
            while count < 7 && start.month == currentMonth {
                oneWeek.append(start)
                start += 24 * 60 * 60
                count += 1
            }
            if oneWeek.count != 7{
                oneWeek += Array<Date?>(repeating: nil, count: 7 - oneWeek.count)
            }
            weekCounter += 1
            dates.append(oneWeek)
        }
        return dates
    }
    
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
