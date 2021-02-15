//
//  ScheduleCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/14.
//

import UIKit
import RxSwift

class ScheduleCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "시험용"
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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:MM"
        return formatter
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage(systemName: "bolt"), for: .normal)
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.3
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 15
        return button
    }()
    
    var schedule: Schedule? {
        didSet {
            guard let title = self.schedule?.title, let start = self.schedule?.start, let end = self.schedule?.end else {return}
            self.titleLabel.text = title
            self.startLabel.text = self.dateFormatter.string(from: start)
            self.endLabel.text = self.dateFormatter.string(from: end)
        }
    }
    
    private let bag = DisposeBag()
    
    var schduleViewModel: ScheduleViewModel? = {
        let viewModel = ScheduleViewModel(schedule: nil)
        return viewModel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.backgroundColor = UIColor.systemPink.cgColor
        self.contentView.addSubview(titleLabel)
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.backgroundColor = UIColor.systemPink.cgColor
        self.contentView.addSubview(titleLabel)
        self.contentView.backgroundColor = .clear
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(startLabel)
        self.contentView.addSubview(endLabel)
        self.contentView.addSubview(checkButton)
        checkButton.center = CGPoint(x: 80, y: 30)
        
        self.schduleViewModel?.scheduleSubject
            .asObservable()
            .filter {$0 != nil}
            .subscribe(onNext: { [weak self] (schedule) in
                self?.titleLabel.text = schedule!.title
                self?.startLabel.text = self?.dateFormatter.string(from: schedule!.start ?? Date())
                self?.endLabel.text = self?.dateFormatter.string(from: schedule!.end ?? Date())
            }).disposed(by: self.bag)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            startLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            startLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            endLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            endLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
