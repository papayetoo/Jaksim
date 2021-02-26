//
//  ToDoCalendar.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/25.
//

import FSCalendar

class ToDoCalendar: FSCalendar {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setConfigure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfigure()
    }
    
    fileprivate func setConfigure() {
        self.locale = Locale(identifier: "ko_kr")
        self.appearance.headerDateFormat = "yy년 MM월"
        self.appearance.weekdayFont = UIFont.systemFont(ofSize: 15)
        self.weekdayHeight = 30
        self.rowHeight = 70
        self.appearance.titleFont = UIFont.systemFont(ofSize: 15)
        self.needsAdjustingViewFrame = false
        self.appearance.headerTitleColor = .black
        self.appearance.headerMinimumDissolvedAlpha = 0
        self.appearance.todaySelectionColor = .systemGreen
        self.appearance.todayColor = nil
        self.appearance.titleTodayColor = self.appearance.titleDefaultColor
        self.appearance.selectionColor = .systemGreen
    }
    
}
