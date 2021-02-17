//
//  DateCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/16.
//

import UIKit

class DateCell: UICollectionViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    var date: Date?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("datecell init coder")
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("datecell init frame")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.date = nil
    }
    
    func setCircularBackground() {
        let width = self.frame.width
        self.layer.cornerRadius = width / 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.7
        self.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        self.setCircularBackground()
        guard let date = self.date  else {
            self.dateLabel.text = ""
            return
        }
        self.dateLabel.text = self.dateFormatter.string(from: date)
    }
}
