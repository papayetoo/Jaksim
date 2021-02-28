//
//  ScheduleCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/14.
//

import UIKit
import SnapKit
import RxSwift

class ScheduleCell: UITableViewCell {
    static let cellId: String = "ScheduleCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "시험용"
        label.font = UIFont(name: "BMEuljiro10yearslaterOTF.otf", size: 13)
        return label
    }()
    
    private let startLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let alaramImgView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.image = UIImage(systemName: "alarm")
//        view.isHidden = true
        return view
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .current
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
    
    
    var schedule: Schedule? {
        didSet {
            guard let title = self.schedule?.title, let start = self.schedule?.start, let contents = self.schedule?.contents, let alarm = self.schedule?.alarm else {return}
            self.titleLabel.text = title
            self.startLabel.text = self.dateFormatter.string(from: start)
            self.alaramImgView.isHidden = !alarm
            self.contentsTextView.text = contents
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.addSubview(titleLabel)
        self.contentView.layer.backgroundColor = UIColor.systemPink.cgColor
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.addSubview(titleLabel)
        self.contentView.layer.backgroundColor = UIColor.systemPink.cgColor
        self.contentView.backgroundColor = .clear
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(alaramImgView)
        self.contentView.addSubview(startLabel)
        self.contentView.addSubview(contentsTextView)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView).offset(10)
            $0.leading.equalTo(self.contentView).offset(100)
        }
        
        alaramImgView.snp.makeConstraints {
            $0.top.equalTo(self.contentView).offset(10)
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(10)
        }
        
        contentsTextView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.contentView).offset(100)
            $0.bottom.trailing.equalTo(self.contentView).offset(-10)
        }
//
        startLabel.snp.makeConstraints {
            $0.leading.equalTo(self.contentView).offset(10)
            $0.top.equalTo(self.contentView).offset(10)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
