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
    private let hours = (0...23).map {String(format: "%02d시", $0)}
    private let minutes = (0...59).map {String(format: "%02d분", $0)}
    private let colon = ":"
    var timeString = ""
    var hour: String = ""
    var minute: String = ""
    var tmStringSubject: BehaviorSubject<String>?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
        self.selectRow(0, inComponent: 0, animated: false)
        self.selectRow(0, inComponent: 1, animated: false)
        self.selectRow(0, inComponent: 2, animated: false)
        
        hour = hours[selectedRow(inComponent: 0)]
        minute = minutes[selectedRow(inComponent: 2)]
        timeString = hour + colon + minute
        tmStringSubject = BehaviorSubject(value: timeString)
        tmStringSubject?.subscribe(onNext: {
            print($0)
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.dataSource = self
        self.delegate = self
        self.selectRow(0, inComponent: 0, animated: false)
        self.selectRow(0, inComponent: 1, animated: false)
        self.selectRow(0, inComponent: 2, animated: false)
        
        hour = hours[selectedRow(inComponent: 0)]
        minute = minutes[selectedRow(inComponent: 2)]
        timeString = hour + colon + minute
        tmStringSubject = BehaviorSubject(value: timeString)
        tmStringSubject?.subscribe(onNext: {
            print($0)
        })
    }
}

extension ToDoTimePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return 1
        case 2:
            return minutes.count
        default:
            assert(false, "잘못된 피커뷰")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return hours[row]
        case 1:
            return colon
        case 2:
            return minutes[row]
        default:
            assert(false, "잘못된 피커뷰")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 1:
            return 30
        default:
            return 70
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = hours[row]
        case 1:
            return
        case 2:
            minute = minutes[row]
        default:
            assert(false, "잘못된 피커뷰 아웃풋")
        }
        timeString = hour + colon + minute
        tmStringSubject?.onNext(timeString)
    }
}
