//
//  UserConfigurationModel.swift
//  ToDoList
//
//  Created by 최광현 on 2021/03/02.
//

import UIKit


class UserConfigurationModel {
    let headerItems: [String] = ["테마 설정", "폰트 설정", "요일 표시", "정보"]
    let specificItemsInHeader: [[String]] = [["화이트모드", "다크모드"], ["위메프 폰트", "나눔바른고딕", "쿠키런 폰트"], ["한글", "영어"], ["오픈소스", "이메일"]]
    private let fontRawValue = ["wemakepriceot-Bold", "NaNumBarunGothicOTFBold", "CookieRunOTF-Bold"]
    private let weekDayRawValue = ["ko_kr", "en_US"]
    var defaultBackgroundColor: String?
    var defaultTitleColor: String?
    var defaultSaturdayColor: String?
    var defaultSundayColor: String?
    var defaultFontName: String?
    var defaultFontSize: Int?
    var defaultWeekDayLocale: String?
    
    let appDefaults = UserDefaults.standard
    
    init() {
        print("UserConfigurationModel init")
        print(UIColor.black)
        if appDefaults.bool(forKey: "FontName") == false,
           appDefaults.bool(forKey: "FontSize") == false,
           appDefaults.bool(forKey: "WeekDayLocale") == false,
           appDefaults.bool(forKey: "TitleColor") == false,
           appDefaults.bool(forKey: "SundayColor") == false,
           appDefaults.bool(forKey: "SaturdayColor") == false,
           appDefaults.bool(forKey: "BackgroundColor") == false {
            // 앱 실행시 초기값 설정.
            print("기존값 없음")
            defaultFontName = "wemakepriceot-Bold"
            defaultFontSize = 15
            defaultWeekDayLocale = "ko_kr"
            defaultBackgroundColor = UIColor.white.hexString()
            defaultTitleColor = UIColor.black.hexString()
            defaultSaturdayColor = UIColor.systemGray.hexString()
            defaultSundayColor = UIColor.systemPink.hexString()
           
            appDefaults.setValue(defaultFontName, forKey: "FontName")
            appDefaults.setValue(defaultFontSize, forKey: "FontSize")
            appDefaults.setValue(defaultWeekDayLocale, forKey: "WeekDayLocale")
            appDefaults.setValue(defaultBackgroundColor, forKey: "BackgroundColor")
            appDefaults.setValue(defaultTitleColor, forKey: "TitleColor")
            appDefaults.setValue(defaultSundayColor, forKey: "SundayColor")
            appDefaults.setValue(defaultSaturdayColor, forKey: "SaturdayColor")
        } else {
            
            defaultFontName = appDefaults.string(forKey: "FontName")
            defaultFontSize = appDefaults.integer(forKey: "FontSize")
            defaultWeekDayLocale = appDefaults.string(forKey: "WeekDayLocale")
            defaultBackgroundColor = appDefaults.string(forKey: "BackgroundColor")
            defaultTitleColor = appDefaults.string(forKey: "TitleColor")
            defaultSaturdayColor = appDefaults.string(forKey: "SaturdayColor")
            defaultSundayColor = appDefaults.string(forKey: "SundayColor")
        }
    }
    
    func setFont(_ fontType: Int) {
        defaultFontName = fontRawValue[fontType]
        appDefaults.setValue(defaultFontName, forKey: "FontName")
        print("폰트 설정 완료")
    }
    
    func setLocale(_ localeType: Int) {
        defaultWeekDayLocale = weekDayRawValue[localeType]
        appDefaults.setValue(defaultWeekDayLocale, forKey: "WeekDayLocale")
    }
    
    func setTheme(_ themeType: Int){
        switch themeType {
        case 0:
            defaultBackgroundColor = UIColor.white.hexString()
            defaultTitleColor = UIColor.black.hexString()
            defaultSaturdayColor = UIColor.systemGray.hexString()
            defaultSundayColor = UIColor.systemPink.hexString()
        case 1:
            defaultBackgroundColor = UIColor.label.hexString()
            defaultTitleColor = UIColor.white.hexString()
            defaultSaturdayColor = UIColor.blue.hexString()
            defaultSundayColor = UIColor.purple.hexString()
        default:
            assert(false, "Invalid Theme selection")
        }
        appDefaults.setValue(defaultBackgroundColor, forKey: "BackgroundColor")
        appDefaults.setValue(defaultTitleColor, forKey: "TitleColor")
        appDefaults.setValue(defaultSundayColor, forKey: "SundayColor")
        appDefaults.setValue(defaultSaturdayColor, forKey: "SaturdayColor")
        print("Theme 설정 완료")
    }
    
}
