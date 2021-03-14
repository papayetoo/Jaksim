//
//  ToDoTabBarController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/05.
//

import UIKit
import UserNotifications
import RxSwift

class ToDoTabBarController: UITabBarController {
    
    private let userConfigurationViewModel =  UserConfigurationViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainVC = ToDoViewController()
        mainVC.view.backgroundColor = .systemBackground
        mainVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "calendar"), tag: 0)
        
        
        let userConfigurationVC = UserConfigurationViewController()
        userConfigurationVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 2)
        userConfigurationVC.tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
        let navigationController = UINavigationController(rootViewController: userConfigurationVC)
        navigationController.navigationBar.barTintColor = .label
        tabBar.tintColor = .systemBackground
        tabBar.barTintColor = .label
        
        viewControllers = [mainVC, navigationController]
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound],
                                                                completionHandler: {didAllow, error in
            switch didAllow {
            case true:
                print(didAllow)
                return
            default:
                assert(false, "알림 권한을 얻지 못했습니다.")
            }
        })
    }
    
}
