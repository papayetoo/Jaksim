//
//  FrameworkTableViewCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/14.
//

import UIKit
import SnapKit

class FrameworkTableViewCell: UITableViewCell {
    
    static let identifier = "FrameworkTableViewCell"
    private let userConfigurationViewModel = UserConfigurationViewModel()
    
    var frameworkTitle: String? {
        didSet {
            guard let title = frameworkTitle else {return}
            frameworkTitleLabel.text = title
        }
    }
    
    private let frameworkTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubview(frameworkTitleLabel)
        frameworkTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            $0.top.equalTo(contentView.snp.top).offset(10)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(frameworkTitleLabel)
        frameworkTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            $0.centerY.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
