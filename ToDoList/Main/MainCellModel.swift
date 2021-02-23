//
//  MainCellModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/22.
//

import UIKit

struct MainCellModel {
    let selectedDate: Date
    let color: UIColor
    let radius: CGFloat
    let weekDays: [Date]
    
    init(date: Date) {
        self.selectedDate = date
        self.color = .white
        self.radius = 0
        let weekStride = stride(from: self.selectedDate.startOfWeek, to: self.selectedDate.endOfWeek, by: 24 * 60 * 60)
        self.weekDays = weekStride.map {$0}
    }
}
