//
//  UserConfigurationCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import UIKit
import SnapKit

class UserConfigurationCell: UITableViewCell {
    static let cellID = "UserConfigurationCell"
    private let userConfigurationViewModel = UserConfigurationViewModel.shared
    
    let optionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(optionLabel)
        optionLabel.snp.makeConstraints({
            $0.centerY.equalTo(contentView.safeAreaLayoutGuide.snp.centerY)
            $0.leading.equalTo(contentView).offset(30)
        })
    }

}
