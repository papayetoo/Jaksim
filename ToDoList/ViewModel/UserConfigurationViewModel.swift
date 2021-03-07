//
//  UserConfigurationViewModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import RxSwift
import RxCocoa

class UserConfigurationViewModel {
    let headerSubject: BehaviorSubject<[String]>?
    let itemSubject: BehaviorSubject<[[String]]>?
    // MARK: 현재 User 설정 Font의 이름
    let fontNameRelay: BehaviorRelay<String?>?
    // MARK: Font 변경시 추적
    let fontNameConfigureRelay: PublishRelay<Int> = PublishRelay()
    // MARK: 현재 Font의 크기
    let fontSizeRelay: BehaviorRelay<Int?>?
    
    // MARK: Theme 선택 relay
    let themeInputRelay: PublishRelay<Int> = PublishRelay()
    // MARK: Theme 제공 relay
    let themeOutputRelay: BehaviorRelay<(String?, String?, String?, String?)>?
    
    // MARK: WeekDay
    let weekDayLocaleConfigureRelay: PublishRelay<Int> = PublishRelay()
    // MARK: Locale 설정
    let weekDaylocaleRelay: BehaviorRelay<String?>?
    
    
    
    // MARK: Section Touch Event 처리
    let sectionNumberRelay: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    // MARK: Touched Section 처리
    let sectionTouchedRelay: BehaviorSubject<Set<Int>> = BehaviorSubject(value: Set<Int>())
    
    
    private var model = UserConfigurationModel()
    private let disposeBag = DisposeBag()
    static let shared = UserConfigurationViewModel()
    
    init() {
        headerSubject = BehaviorSubject(value: model.headerItems)
        itemSubject = BehaviorSubject(value: model.specificItemsInHeader)
        fontNameRelay = BehaviorRelay(value: model.defaultFontName)
        fontSizeRelay = BehaviorRelay(value: model.defaultFontSize)
        weekDaylocaleRelay = BehaviorRelay(value: model.defaultWeekDayLocale)
        themeOutputRelay =
            BehaviorRelay(value: (model.defaultBackgroundColor, model.defaultTitleColor, model.defaultSaturdayColor, model.defaultSundayColor))
        
        fontNameConfigureRelay
            .subscribe(onNext:{ [weak self] in
                self?.model.setFont($0)
                self?.fontNameRelay?.accept(self?.model.defaultFontName)
            })
            .disposed(by: disposeBag)
        
        weekDayLocaleConfigureRelay
            .subscribe(onNext: {[weak self] in
                self?.model.setLocale($0)
                print(self?.model.defaultWeekDayLocale)
                self?.weekDaylocaleRelay?.accept(self?.model.defaultWeekDayLocale)
            })
            .disposed(by: disposeBag)
        
        themeInputRelay
            .subscribe(onNext: { [weak self] in
                self?.model.setTheme($0)
                let newTheme = (self?.model.defaultBackgroundColor, self?.model.defaultTitleColor,
                                self?.model.defaultSaturdayColor, self?.model.defaultSundayColor)
                self?.themeOutputRelay?.accept(newTheme)
            })
            .disposed(by: disposeBag)

        sectionNumberRelay.subscribe(onNext: { [weak self] sectionNumber in
            guard let number = sectionNumber, var selectedSections = try? self?.sectionTouchedRelay.value() else {return}
            if selectedSections.contains(number) == false {
                selectedSections.insert(number)
            } else {
                selectedSections.remove(number)
            }
            print("selected Sections :", selectedSections)
            self?.sectionTouchedRelay.onNext(selectedSections)
        })
        .disposed(by: disposeBag)
    }
}
