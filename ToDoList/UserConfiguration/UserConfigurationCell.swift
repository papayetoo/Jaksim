//
//  UserConfigurationCell.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import UIKit

class UserConfigurationCell: UITableViewCell {
    static let cellID = "UserConfigurationCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @available(iOS 14.0, *)
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var contentConfig = defaultContentConfiguration().updated(for: state)
        contentConfig.text = "Hello Word"
            
        contentConfiguration = contentConfig
    }

}
