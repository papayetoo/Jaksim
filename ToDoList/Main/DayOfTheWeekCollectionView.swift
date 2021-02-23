//
//  DayOfTheWeekCollectionView.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/23.
//

import UIKit

class DayOfTheWeekCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private let cellId = "DayofTheWeekCell"
    let DaysOfTheWeek: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.register(DayOfTheWeekCell.self, forCellWithReuseIdentifier: cellId)
        self.backgroundColor = .white
        self.dataSource = self
        self.delegate = self
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.register(DayOfTheWeekCell.self, forCellWithReuseIdentifier: cellId)
        self.backgroundColor = .white
        self.dataSource = self
        self.delegate = self
    }
}

extension DayOfTheWeekCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DaysOfTheWeek.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? DayOfTheWeekCell else {return UICollectionViewCell()}
        cell.dayOfTheWeekLabel.text = DaysOfTheWeek[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }
}


