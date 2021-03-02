//
//  UserConfigurationViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import RxSwift

struct UserConfigurationViewModel {
    let itemModel: BehaviorSubject<UserConfigurationModel> = BehaviorSubject(value: UserConfigurationModel())
}
