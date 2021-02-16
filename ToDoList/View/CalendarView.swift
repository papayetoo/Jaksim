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
        self.dataSource = self
        self.delegate = self
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.register(DateCell.self, forCellWithReuseIdentifier: self.cellId)
    }
    
}


extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.datesOfMonth?.count
        return count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as? DateCell else {return UICollectionViewCell()}
        if let date = self.datesOfMonth?[indexPath.item] {
            cell.date = date
        } else {
            cell.backgroundColor = .systemGray2
        }
        return cell
    }
}

extension CalendarView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DateCell else {return}
        cell.contentView.backgroundColor = .black
        cell.dateLabel.textColor = .red
        
        let cells = collectionView.visibleCells
        let selectedCells = cells.filter {$0.contentView.backgroundColor == UIColor.black}
        
        if selectedCells.count < 2 {return}
        let selectedIndexPaths = selectedCells.map {collectionView.indexPath(for: $0)}.compactMap {$0}.sorted()
        
        var startPath = selectedIndexPaths[0]
        while startPath <= selectedIndexPaths[1] {
            guard let rangedCell = collectionView.cellForItem(at: startPath) as? DateCell else {return}
            rangedCell.contentView.backgroundColor = .black
            rangedCell.dateLabel.textColor = .red
            startPath = IndexPath(item: startPath.item + 1, section: startPath.section)
        }
//        let end = selectedIndexPaths[1]
//        while start <= end {
//            guard let rangedCell = collectionView.cellForItem(at: start) as? DateCell else {return}
//            rangedCell.contentView.backgroundColor = .black
//            rangedCell.dateLabel.textColor = .red
//            start += incrementIndexPath
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

