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
    
    private let viewModel = UserConfigurationViewModel()
    private let configurationItems: [String] = ["테마 설정", "폰트 설정", "언어 설정", "정보"]
    private let configurationSpecificItems: [[String]] = [["사이버펑크 테마", "배트맨 테마"], ["글씨 크기 설정", "글씨제 설정"], ["한국어", "영어"], ["오픈소스", "정보"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        navigationItem.title = "설정"
        let attributes = [NSAttributedString.Key.font: UIFont(name: "wemakepriceot-Bold", size: 30)]
        UINavigationBar.appearance().titleTextAttributes = attributes
        navigationController?.navigationBar.prefersLargeTitles = true
        setConfigurationTableView()
    }
    
    func setConfigurationTableView() {
        view.addSubview(configurationTableView)
        configurationTableView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        configurationTableView.register(UserConfigurationCell.self, forCellReuseIdentifier: UserConfigurationCell.cellID)
        configurationTableView.dataSource = self
        configurationTableView.delegate = self
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
        return configurationItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configurationSpecificItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserConfigurationCell.cellID, for: indexPath) as? UserConfigurationCell else {return UITableViewCell()}
        
        cell.textLabel?.text = configurationSpecificItems[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UserConfigurationSectionView()
        sectionView.titleLabel.text = configurationItems[section]
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

