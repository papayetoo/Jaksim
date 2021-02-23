//
//  MainCellHeader.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/22.
//

import UIKit
import SnapKit

class MainCellHeader: UICollectionReusableView {
    
    private let weekDayNames = ["일", "월", "화", "수", "목", "금", "토"]
    private let cellId = "Header"
    
    let labels: [UILabel] = Array<UILabel>(repeating: .init(), count: 7)
    
    let horizontalStackView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flowLayout)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("reusableView init coder")
        self.backgroundColor = .white
        self.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalTo(self)
        }
        self.horizontalStackView.register(DateCell.self, forCellWithReuseIdentifier: cellId)
        self.horizontalStackView.dataSource = self
        self.horizontalStackView.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("reusableView init frame")
    }

}

extension MainCellHeader: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? DateCell else {return UICollectionViewCell()}
        cell.dateLabel.text = weekDayNames[indexPath.item]
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
