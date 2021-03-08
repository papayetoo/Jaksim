//
//  ToDoTimePickerView.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/07.
//

import UIKit
import RxSwift
import RxCocoa

class ToDoTimePickerView: UIPickerView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private let hours = (0...23).map {$0}
    private let minutes = (0...59).map {$0}
    private let userConfigurationViewModel = UserConfigurationViewModel.shared
    var timeString = ""
    var hour: String = ""
    var minute: String = ""
    var toDoTimePickerDelegate: ToDoTimePickerDelegate?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
        self.selectRow(0, inComponent: 0, animated: false)
        self.selectRow(0, inComponent: 1, animated: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.dataSource = self
        self.delegate = self
        self.selectRow(0, inComponent: 0, animated: false)
        self.selectRow(0, inComponent: 1, animated: false)
    }
    
}

extension ToDoTimePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        default:
            assert(false, "잘못된 피커뷰")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(hours[row])시"
        case 1:
            return "\(minutes[row])분"
        default:
            assert(false, "잘못된 피커뷰")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 70
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            toDoTimePickerDelegate?.hour(hours[row])
        case 1:
            toDoTimePickerDelegate?.minute(minutes[row])
        default:
            assert(false, "잘못된 피커뷰 아웃풋")
        }
    }
    
}


protocol ToDoTimePickerDelegate {
    func hour(_ selectedHour: Int)
    func minute(_ selectedMinute: Int)
}
