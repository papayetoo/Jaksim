//
//  UserConfigurationViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import UIKit
import SnapKit
import RxSwift

class UserConfigurationViewController: UIViewController {
    
    let colorSubject: PublishSubject<Any?> = PublishSubject()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let changeButton: UIButton = {
        let button = UIButton()
        button.setTitle("change", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let configurationTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel = UserConfigurationViewModel.shared
    // MARK: DiposeBag
    private var disposeBag = DisposeBag()
    // MARK: SelectedSection set
    private var selectedSection = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
        setNavigationBar()
        setConfigurationTableView()
    }
    
    func setNavigationBar() {
        navigationItem.title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        // 네비게이션바 폰트 변경
        viewModel.fontNameRelay?
            .filter {$0 != nil}
            .subscribe(onNext: {[weak self] font in
                let largeTitleAttrs = [NSAttributedString.Key.font: UIFont(name: font!, size: 50), NSAttributedString.Key.strokeColor: UIColor.label]
                let titleAttrs = [NSAttributedString.Key.font: UIFont(name: font!, size: 20),
                                  NSAttributedString.Key.strokeColor: UIColor.label]
                self?.navigationController?.navigationBar.largeTitleTextAttributes = largeTitleAttrs
                self?.navigationController?.navigationBar.titleTextAttributes = titleAttrs
            })
            .disposed(by: disposeBag)
    }
    
    
    func setConfigurationTableView() {
        view.addSubview(configurationTableView)
        configurationTableView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        configurationTableView.register(UserConfigurationCell.self, forCellReuseIdentifier: UserConfigurationCell.cellID)
        configurationTableView.dataSource = self
        configurationTableView.delegate = self
        configurationTableView.separatorStyle = .none
    }
    
    @objc func touchChangeButton(_ sender: UIButton){
        var colorData: NSData?
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor.systemPink, requiringSecureCoding: false) as? NSData
            colorData = data
        } catch {
            print(error.localizedDescription)
        }
        UserDefaults.standard.setValue(colorData, forKey: "FontColor")
    }

}

extension UserConfigurationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        viewModel.headerSubject?
            .map {$0.count}
            .bind(onNext: {
                numberOfSections = $0
            })
            .disposed(by: disposeBag)
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = try? viewModel.itemSubject?.value() else {return 0}
        
        if selectedSection.contains(section) {
            return items[section].count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserConfigurationCell.cellID, for: indexPath) as? UserConfigurationCell else {return UITableViewCell()}
        viewModel.itemSubject?
            .map {$0[indexPath.section]}
            .bind(onNext: {
                cell.optionLabel.text = $0[indexPath.row]
            })
            .disposed(by: disposeBag)
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                cell.optionLabel.font = UIFont(name: "wemakepriceot-Bold", size: 18)
            } else if indexPath.row == 1 {
                cell.optionLabel.font = UIFont(name: "NanumBarunGothicOTFBold", size: 18)
            } else if indexPath.row == 2 {
                cell.optionLabel.font = UIFont(name: "CookieRunOTF-Bold", size: 18)
            }
        default:
            viewModel.fontNameRelay?
                .filter({$0 != nil})
                .bind(onNext: {cell.optionLabel.font = UIFont(name: $0!, size: 18)})
                .disposed(by: disposeBag)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))

        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray, for: .selected)
        viewModel.headerSubject?
            .bind(onNext: { button.setTitle($0[section], for: .normal)})
            .disposed(by: disposeBag)
        viewModel.fontNameRelay?
            .filter({$0 != nil})
            .bind(onNext: {button.titleLabel?.font = UIFont(name: $0!, size: 18)})
            .disposed(by: disposeBag)
        button.tag = section
        button.addTarget(self, action: #selector(headerButtonTouched(_:)), for: .touchUpInside)

        let indicator = UIButton()
        indicator.setImage(UIImage(systemName: "chevron.compact.forward"), for: .normal)
        indicator.setImage(UIImage(systemName: "chevron.compact.down"), for: .selected)


        sectionHeaderView.addSubview(button)
        button.snp.makeConstraints{
            $0.centerY.equalTo(sectionHeaderView.snp.centerY)
            $0.leading.equalTo(sectionHeaderView.snp.leading).inset(10)
            $0.width.lessThanOrEqualTo(tableView.frame.width)
        }
//        let sectionHeaderView = UserConfigurationSectionView()
//        viewModel.headerSubject?
//            .bind(onNext: {sectionHeaderView.titleButton.setTitle($0[section], for: .normal)})
//            .disposed(by: disposeBag)
//        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(sectionViewTapped(_:)))
//        sectionHeaderView.addGestureRecognizer(tapGestureRecongnizer)
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("\(indexPath) 테마 설정 클릭됨")
            viewModel
                .themeInputRelay
                .accept(indexPath.row)
        case 1:
            print("\(indexPath) 폰트 설정 클릭됨")
            viewModel
                .fontNameConfigureRelay
                .accept(indexPath.row)
        case 2:
            print("\(indexPath) locale 설정 변경")
            viewModel
                .weekDayLocaleConfigureRelay
                .accept(indexPath.row)
        default:
            print(false, "Invalid row Selection")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @objc
    func headerButtonTouched(_ sender: UIButton){
        
        if selectedSection.contains(sender.tag) == true {
            sender.isSelected = false
            selectedSection.remove(sender.tag)
            configurationTableView.deleteRows(at: indexPathsForSection(at: sender.tag), with: .fade)
        } else {
            sender.isSelected = true
            selectedSection.insert(sender.tag)
            configurationTableView.insertRows(at: indexPathsForSection(at: sender.tag), with: .fade)
        }
    }
    
    @objc
    func sectionViewTapped(_ sender: UITapGestureRecognizer){
        print("touched")
    }
    
    func indexPathsForSection(at section: Int) -> [IndexPath] {
        guard let items = try? viewModel.itemSubject?.value() else {return []}
        let indexPaths = (0..<items[section].count).map {IndexPath(row: $0, section: section)}
        return indexPaths
    }
}

