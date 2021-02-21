//
//  ScheduleAddViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/17.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ScheduleAddViewController: UIViewController {
    
    private let vertiacalOffset: CGFloat = 40
    private let labelWidth: CGFloat = 80
    private let leadingOffset: CGFloat = 30
    
    var completionHandler: (() -> Void)?
    let disposeBag = DisposeBag()
    var viewModel = ScheduleAddViewModel()
    
    let scheduleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "일정"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let scheduleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "일정 제목을 입력해주세요"
        return textField
    }()
    
    // MARK: 시작 시간 레이블
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "일정 시작"
        return label
    }()
    
    // MARK: 시작 시간 픽커
    let startTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.datePickerMode = .time
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    // MARK: 알람 체크 라벨
    let alarmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "알람"
        return label
    }()
    
    // MARK: 알람 체크 세그먼트
    let alarmSegment: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "On", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Off", at: 1, animated: true)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.tintColor = .systemBlue
        return segmentControl
    }()
    
    // MARK: 일정 내용 레이블
    let scheduleContentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "일정 내용"
        return label
    }()
    
    // MARK: 일정 내용 입력 텍스트뷰
    let scheduleContentsTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 0.4
        return textView
    }()
    
    // MARK: 저장 버튼
    let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    // MARK: 취소 버튼
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    // MAKR: 선택된 날
    var selectedDate: Date? {
        didSet {
            self.startTimePicker.date = selectedDate ?? Date()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        self.setSubViews()
        self.setBinding()
    }
    
    // MARK: presenting view에서 데이터 리로드 하기 위해서
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // isBeingDismissed 라는 함수가 있음.
//        if isBeingDismissed == true {
//            guard let presentingViewController = self.presentedViewController as? MainViewController else {
//                print("self.presentingViewController is nil")
//                return}
//            print("completed")
//            presentingViewController.getSchedule()
//            presentingViewController.timeLineTbView.reloadData()
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setSubViews() {
        self.view.addSubview(self.scheduleTitleLabel)
        self.view.addSubview(self.scheduleTextField)
        self.view.addSubview(self.startTimeLabel)
        self.view.addSubview(self.startTimePicker)
        self.view.addSubview(self.alarmLabel)
        self.view.addSubview(self.alarmSegment)
        self.view.addSubview(self.scheduleContentsLabel)
        self.view.addSubview(self.scheduleContentsTextView)
        
        self.view.addSubview(self.saveButton)
        self.view.addSubview(self.cancelButton)
        
        self.scheduleTitleLabel.snp.makeConstraints{
            $0.leading.equalTo(self.view).offset(self.leadingOffset)
            $0.trailing.lessThanOrEqualTo(self.view.snp.centerX)
            $0.top.equalTo(self.view).offset(self.vertiacalOffset)
            $0.width.equalTo(self.labelWidth)
            $0.height.equalTo(30)
        }
        
        self.scheduleTextField.snp.makeConstraints{
            $0.leading.greaterThanOrEqualTo(self.scheduleTitleLabel.snp.leading).offset(self.labelWidth + 30)
            $0.top.equalTo(self.view).offset(self.vertiacalOffset)
            $0.width.lessThanOrEqualTo(200)
            $0.height.equalTo(30)
        }
        
        self.startTimeLabel.snp.makeConstraints{
            $0.leading.equalTo(self.view).offset(self.leadingOffset)
            $0.trailing.lessThanOrEqualTo(self.view.snp.centerX)
            $0.top.equalTo(self.scheduleTitleLabel.snp.bottom).offset(self.vertiacalOffset)
            $0.width.equalTo(self.labelWidth)
            $0.height.equalTo(30)
        }
        
        self.startTimePicker.snp.makeConstraints{
            $0.leading.greaterThanOrEqualTo(self.startTimeLabel.snp.leading).offset(self.labelWidth + 30)
            $0.top.equalTo(self.startTimeLabel)
            $0.width.greaterThanOrEqualTo(100)
            $0.height.equalTo(30)
        }
        
        self.alarmLabel.snp.makeConstraints{
            $0.leading.equalTo(self.view).offset(self.leadingOffset)
            $0.trailing.lessThanOrEqualTo(self.view.snp.centerX)
            $0.top.equalTo(self.startTimeLabel.snp.bottom).offset(self.vertiacalOffset)
            $0.width.equalTo(self.labelWidth)
            $0.height.equalTo(30)
        }
        
        self.alarmSegment.snp.makeConstraints{
            $0.leading.greaterThanOrEqualTo(self.alarmLabel.snp.leading).offset(self.labelWidth + 30)
            $0.top.equalTo(self.alarmLabel)
            $0.width.lessThanOrEqualTo(100)
            $0.height.equalTo(30)
        }
        
        self.scheduleContentsLabel.snp.makeConstraints{
            $0.leading.equalTo(self.view).offset(self.leadingOffset)
            $0.trailing.lessThanOrEqualTo(self.view.snp.centerX)
            $0.top.equalTo(self.alarmLabel.snp.bottom).offset(self.vertiacalOffset)
            $0.width.equalTo(self.labelWidth)
            $0.height.equalTo(30)
        }
        
        self.scheduleContentsTextView.snp.makeConstraints{
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.top.equalTo(self.scheduleContentsLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(self.leadingOffset)
            $0.width.lessThanOrEqualTo(self.view.frame.width - 40)
            $0.height.equalTo(200)
        }
        
        self.saveButton.snp.makeConstraints{
            $0.centerX.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.centerX).offset(-20)
            $0.top.greaterThanOrEqualTo(self.scheduleContentsTextView.snp.bottom).offset(self.vertiacalOffset)
        }
        
        self.cancelButton.snp.makeConstraints{
            $0.centerX.greaterThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.centerX).offset(20)
            $0.top.greaterThanOrEqualTo(self.scheduleContentsTextView.snp.bottom).offset(self.vertiacalOffset)
        }
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTouched), for: .touchUpInside)
        
    }
    
    private func setBinding(){
        
        self.saveButton.rx.tap
            .subscribe(onNext: { [weak self] void in
                guard let completed = self?.completionHandler else {return}
                self?.viewModel.saveButtonTouchedRelay.accept(void)
                completed()
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.scheduleTextField.rx.text
            .orEmpty
            .bind(to: self.viewModel.scheduleTitleRelay)
            .disposed(by: self.disposeBag)
        self.scheduleContentsTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: self.viewModel.scheduleContentsRelay)
            .disposed(by: self.disposeBag)
        self.startTimePicker.rx.date
            .distinctUntilChanged()
            .bind(to: self.viewModel.startTimeRelay)
            .disposed(by: self.disposeBag)
        self.alarmSegment.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .bind(to: self.viewModel.alarmRelay)
            .disposed(by: self.disposeBag)
    }
    
    @objc func cancelButtonTouched() {
        self.dismiss(animated: true, completion: nil)
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
