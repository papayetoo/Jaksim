//
//  UserConfigurationSectionView.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import UIKit
import SnapKit

class UserConfigurationSectionView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private let viewModel = UserConfigurationViewModel.shared

    let titleButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .white
        addSubview(titleButton)
        titleButton.snp.makeConstraints{
            $0.centerY.equalTo(self)
            $0.leading.equalTo(self.snp.leading).offset(10)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addSubview(titleButton)
        
        titleButton.snp.makeConstraints{
            $0.centerY.equalTo(self)
            $0.leading.equalTo(self.snp.leading).offset(10)
        }
        addSubview(toggleButton)
        toggleButton.snp.makeConstraints{
            $0.centerY.equalTo(self)
            $0.trailing.equalTo(self.snp.trailing).offset(-10)
        }
    }
    
    func bindUI() {
        viewModel.fontNameRelay?
            .filter({$0 != nil})
            .subscribe(onNext:{ [weak self] font in
                self?.titleButton.titleLabel?.font = UIFont(name: font!, size: 13)
            })
    }
}
