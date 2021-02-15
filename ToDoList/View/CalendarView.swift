//
//  CalendarView.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/15.
//

import UIKit

class CalendarView: UICollectionView {
    
    private let cellId = "DateCell"
    
    var currentDate: Date? {
        didSet {
            self.datesOfMonth = currentDate?.datesOfMonth.flatMap {$0}
        }
    }
    var datesOfMonth: [Date?]?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("required init? coder")
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
        self.dataSource = self
        self.delegate = self
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        print(self.datesOfMonth?.count)
    }
}


extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.datesOfMonth?.count
        return count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath)
        if datesOfMonth?[indexPath.item] != nil {
            cell.backgroundColor = .systemRed
        } else {
            cell.backgroundColor = .systemBlue
        }
        return cell
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
