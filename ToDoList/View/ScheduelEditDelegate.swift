//
//  ScheduelEditDelegate.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/07.
//

import UIKit

protocol ScheduleCellDelegate {
    func edit(_ cell: ScheduleCell)
    func toggleHide(_ cell: ScheduleCell)
}
