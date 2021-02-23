//
//  WeekCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/20.
//

import UIKit
import SnapKit

class WeekDateCell: UICollectionViewCell {

    var isToday: Bool? {
        didSet {
            guard let newValue = self.isToday else {return}
            if newValue {
                self.contentView.layer.cornerRadius = 30
                self.contentView.layer.backgroundColor = UIColor.systemPink.cgColor
//                self.arcLayer.fillColor = UIColor.systemPink.cgColor
//                self.layer.insertSublayer(arcLayer, at: 0)
            } else {
                self.contentView.layer.cornerRadius = 0
                self.contentView.layer.backgroundColor = UIColor.white.cgColor
//                self.arcLayer.removeFromSuperlayer()
            }
        }
    }
    
    var date: Date? {
        didSet{
            guard let date = self.date else { return }
            print(date)
            self.dateLabel.text = self.dateFormatter.string(from: date)
        }
    }
    
    let arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    let dateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("test", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "d"
        return formatter
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("week cell init coder")
        self.contentView.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints{
            $0.center.equalTo(self.contentView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("week cell init frame")
        self.contentView.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints{
            $0.center.equalTo(self.contentView)
        }
    }
    
    override func awakeFromNib() {
        print("awakeFromNib")
    }
    
}

