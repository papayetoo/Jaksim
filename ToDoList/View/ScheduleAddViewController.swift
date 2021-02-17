//
//  ScheduleAddViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/17.
//

import UIKit

class ScheduleAddViewController: UIViewController {
    let helloLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello Schedule add View controller"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBlue
        self.view.addSubview(self.helloLabel)
        NSLayoutConstraint.activate([
            self.helloLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.helloLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
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
