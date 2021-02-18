//
//  ScheduleAddViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/17.
//

import UIKit

class ScheduleAddViewController: UIViewController {
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.text = "일정"
        return label
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        textField.backgroundColor = .systemGray
        return textField
    }()
    
    let titleView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = .current
        picker.datePickerMode = .time
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        self.setTitleView()
        
    }
    
    func setTitleView() {
        self.view.addSubview(self.titleView)
        NSLayoutConstraint.activate([
            self.titleView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.titleView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.titleView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.titleView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])
        self.titleView.addArrangedSubview(self.titleLabel)
        self.titleView.addArrangedSubview(self.titleTextField)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
