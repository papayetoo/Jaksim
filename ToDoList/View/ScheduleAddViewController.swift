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
    private let userConfigurationViewModel = UserConfigurationViewModel.shared
    
    // MARK: 일정 입력을 위해 선택된 날짜를 표시
    let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: 제목 입력
    let titleField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: 시작 시간 레이블
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "일정 시작"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: 시작 시간 픽커
    let startTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ko_kr")
        datePicker.datePickerMode = .dateAndTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    // MARK: 시작 시간 피커 텍스트필드
    let startTimeTextField: UITextField = {
        let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.borderStyle = .roundedRect
        textfield.textColor = .systemGray
        textfield.textAlignment = .center
        return textfield
    }()
    
    let pickerView: ToDoTimePickerView = {
        let view = ToDoTimePickerView()
        return view
    }()

    // MARK: 알람 체크 라벨
    let alarmLabel: UILabel = {
        let label = UILabel()
        label.text = "알람"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: 알람 체크 세그먼트
    let alarmSegment: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "On", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Off", at: 1, animated: true)
        segmentControl.tintColor = .systemBlue
        segmentControl.selectedSegmentIndex = 0
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
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
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "wemakepriceot-Bold", size: 20)
        button.setTitle("저장", for: .normal)
        button.layer.cornerRadius = button.bounds.size.width * 0.5
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.darkGray, for: .disabled)
        button.sizeToFit()
        return button
    }()
    
    // MARK: 취소 버튼
    let cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "wemakepriceot-Bold", size: 20)
        button.setTitle("취소", for: .normal)
        button.layer.cornerRadius = button.bounds.size.width * 0.5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        setSubViews()
        setBinding()
        titleField.becomeFirstResponder()
        scheduleContentsTextView.delegate = self
        
    }
    
    // MARK: presenting view에서 데이터 리로드 하기 위해서
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: 키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setSubViews() {
        view.addSubview(selectedDateLabel)
        view.addSubview(titleField)
        view.addSubview(startTimeLabel)
//        view.addSubview(startTimePicker)
        view.addSubview(startTimeTextField)
        view.addSubview(alarmLabel)
        view.addSubview(alarmSegment)
        view.addSubview(scheduleContentsLabel)
        view.addSubview(scheduleContentsTextView)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        selectedDateLabel.snp.makeConstraints{
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(leadingOffset)
            $0.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(vertiacalOffset)
            $0.height.equalTo(30)
        }
        
        titleField.snp.makeConstraints{
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(leadingOffset - 3)
            $0.top.equalTo(selectedDateLabel.snp.bottom).offset(vertiacalOffset)
            $0.height.equalTo(40)
        }
        
        startTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(leadingOffset)
            $0.trailing.lessThanOrEqualTo(view.snp.centerX)
            $0.top.equalTo(titleField.snp.bottom).offset(vertiacalOffset)
            $0.width.equalTo(labelWidth)
            $0.height.equalTo(30)
        }
        
//        startTimePicker.snp.makeConstraints{
//            $0.leading.greaterThanOrEqualTo(titleField.snp.leading).offset(labelWidth + 30)
//            $0.top.equalTo(startTimeLabel)
//            $0.width.greaterThanOrEqualTo(100)
//            $0.height.equalTo(30)
//        }
        startTimeTextField.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(titleField.snp.leading).offset(labelWidth + 30)
            $0.top.equalTo(startTimeLabel)
            $0.width.equalTo(200)
            $0.height.equalTo(30)
        }
        startTimeTextField.inputView = pickerView
        pickerView.tmStringSubject?
            .bind(onNext: {[weak self] in self?.startTimeTextField.text = $0})
            .disposed(by: disposeBag)
        
        alarmLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaInsets).offset(leadingOffset)
            $0.trailing.lessThanOrEqualTo(view.snp.centerX)
            $0.top.equalTo(startTimeLabel.snp.bottom).offset(vertiacalOffset)
            $0.width.equalTo(labelWidth)
            $0.height.equalTo(30)
        }
        
        alarmSegment.snp.makeConstraints{
            $0.leading.greaterThanOrEqualTo(alarmLabel.snp.leading).offset(labelWidth + 30)
            $0.top.equalTo(alarmLabel)
            $0.width.lessThanOrEqualTo(100)
            $0.height.equalTo(30)
        }
        
        scheduleContentsLabel.snp.makeConstraints{
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(leadingOffset)
            $0.trailing.lessThanOrEqualTo(view.snp.centerX)
            $0.top.equalTo(alarmLabel.snp.bottom).offset(vertiacalOffset)
            $0.width.equalTo(labelWidth)
            $0.height.equalTo(30)
        }
        
        scheduleContentsTextView.snp.makeConstraints{
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(scheduleContentsLabel.snp.bottom).offset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(leadingOffset)
            $0.width.lessThanOrEqualTo(view.frame.width - 40)
            $0.height.equalTo(200)
        }
        
        saveButton.snp.makeConstraints{
            $0.centerX.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.centerX).offset(-50)
            $0.top.greaterThanOrEqualTo(scheduleContentsTextView.snp.bottom).offset(vertiacalOffset)
        }
        
        cancelButton.snp.makeConstraints{
            $0.centerX.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.centerX).offset(50)
            $0.top.greaterThanOrEqualTo(scheduleContentsTextView.snp.bottom).offset(vertiacalOffset)
        }
        cancelButton.addTarget(self, action: #selector(cancelButtonTouched), for: .touchUpInside)
        
    }
    
    private func setBinding(){
        
        userConfigurationViewModel.fontNameRelay?
            .filter {$0 != nil}
            .bind(onNext: {
                [unowned self] fontName in
                self.selectedDateLabel.font = UIFont(name: fontName!, size: 30)
                self.titleField.font = UIFont(name: fontName!, size: 25)
                self.startTimeLabel.font = UIFont(name: fontName!, size: 20)
                self.alarmLabel.font = UIFont(name: fontName!, size: 18)
                self.scheduleContentsLabel.font = UIFont(name: fontName!, size: 18)
                self.scheduleContentsTextView.font = UIFont(name: fontName!, size: 18)
            })
            .disposed(by: disposeBag)
        
        viewModel.dateStringRelay
            .subscribe(onNext: { [unowned self] dateString in
                self.selectedDateLabel.text = dateString
            })
            .disposed(by: disposeBag)
        
//        viewModel.startTimeRelay
//            .subscribe(onNext: { [weak self] date in
//                self?.startTimePicker.date = date
//            })
//            .disposed(by: disposeBag)
        
        viewModel.saveButtonEnableRelay
            .subscribe(onNext: {[weak self] isEnabled in self?.saveButton.isEnabled = isEnabled})
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] void in
                guard let completed = self?.completionHandler else {return}
                self?.viewModel.saveButtonTouchedRelay.accept(void)
                completed()
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        titleField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(viewModel.scheduleTitleRelay)
            .disposed(by: disposeBag)
        
        scheduleContentsTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(viewModel.scheduleContentsRelay)
            .disposed(by: disposeBag)
        
        startTimePicker.rx.date
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Date())
            .drive(viewModel.startTimeRelay)
            .disposed(by: disposeBag)
        
        // Observable이 Error 나 Complete 발생할 수 있기 때문에
        // Driver로 변환해서 처리
        alarmSegment.rx.selectedSegmentIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(viewModel.alarmRelay)
            .disposed(by: disposeBag)
    }
    
    @objc func cancelButtonTouched() {
        viewModel.disposeBag = DisposeBag()
        self.dismiss(animated: true, completion: {
            print("after cancel button touched completion")
        })
    }
}


extension ScheduleAddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        view.frame.origin.y = -150
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.frame.origin.y = 0
    }
}
