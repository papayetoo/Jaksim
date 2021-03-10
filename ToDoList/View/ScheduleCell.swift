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
    
    private let userConfigureViewModel = UserConfigurationViewModel.shared
    
    private let disposeBag = DisposeBag()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.systemGray.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        return view
    }()
    
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
    
    let contentsTextView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let alaramImgView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "alarm")
        return view
    }()
    
    let pencilButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.setImage(UIImage(systemName: "pencil.circle.fill"), for: .selected)
        button.tintColor = .systemBlue
        return button
    }()
    
    var scheduleEditDelegate: ScheduleCellDelegate?
    
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
//            self.startLabel.text = self.dateFormatter.string(from: start)
            self.alaramImgView.isHidden = alarm ? false : true
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
        setContainerView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.top.equalTo(contentView).offset(10)
            $0.trailing.bottom.equalTo(contentView).offset(-10)
        }
        
        containerView.addSubview(titleLabel)
        userConfigureViewModel.fontNameRelay?
            .filter {$0 != nil}
            .subscribe(onNext: { [weak self] fontName in
                self?.titleLabel.font = UIFont(name: fontName!, size: 15)
                self?.startLabel.font = UIFont(name: fontName!, size: 15)
                self?.contentsTextView.font = UIFont(name: fontName!, size: 15)
            })
            .disposed(by: disposeBag)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(10)
            $0.leading.equalTo(containerView).offset(100)
        }

        containerView.addSubview(alaramImgView)
        alaramImgView.snp.makeConstraints {
           $0.centerY.equalTo(titleLabel.snp.centerY)
           $0.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
        
        containerView.addSubview(startLabel)
        
        startLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(10)
            $0.leading.equalTo(containerView).offset(10)
        }

        containerView.addSubview(contentsTextView)
        contentsTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.bottom.trailing.equalTo(containerView).offset(-10)
            $0.leading.equalTo(containerView).offset(100)
        }
        
        containerView.addSubview(pencilButton)
        pencilButton.snp.makeConstraints {
           $0.centerY.equalTo(titleLabel.snp.centerY)
           $0.trailing.equalTo(containerView).offset(-10)
       }
        pencilButton.addTarget(self, action: #selector(touchPencilButton(_:)), for: .touchUpInside)
    }
    
    @objc
    func touchPencilButton(_ sender: UIButton) {
        guard let schedule = schedule else {return}
        scheduleEditDelegate?.edit(schedule)
    }
}
