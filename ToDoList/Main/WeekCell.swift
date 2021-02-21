//
//  WeekCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/20.
//

import UIKit
import SnapKit

class WeekCell: UICollectionViewCell {

    var isToday: Bool = false {
        didSet {
            if isToday {
                self.contentView.layer.cornerRadius = 25
                self.contentView.layer.backgroundColor = UIColor.systemPink.cgColor
            } else {
                self.contentView.layer.cornerRadius = 0
                self.contentView.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    
    var date: Date? {
        didSet {
            guard let date = self.date else {return}
            dateLabel.text = self.dateFormatter.string(from: date)
        }
    }
    
    private let arcLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private let dateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("test", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("week cell init frame")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints{
            $0.center.equalTo(self.contentView)
        }
//        self.contentView.addSubview(self.dateButton)
//        self.dateButton.snp.makeConstraints{
//            $0.center.equalTo(self.contentView)
//        }
    }
    
    func arcPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.addArc(withCenter: self.contentView.center, radius: 30, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        return path
    }
    
    
}
