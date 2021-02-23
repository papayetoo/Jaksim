//
//  MainCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DayOfTheWeekCell: UICollectionViewCell {
    
    let dayOfTheWeekLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.addSubview(self.dayOfTheWeekLabel)
        self.dayOfTheWeekLabel.snp.makeConstraints{
            $0.center.equalTo(self.contentView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.dayOfTheWeekLabel)
        self.dayOfTheWeekLabel.snp.makeConstraints{
            $0.center.equalTo(self.contentView)
        }
    }
    
    
}
