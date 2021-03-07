////
////  TodoFonts.swift
////  ToDoList
////
////  Created by 최광현 on 2021/03/06.
////
//
//import UIKit
//
//protocol ToDoFont: Equatable, ExpressibleByStringLiteral {
//    
//    var bold: String {get}
//    var semibold: String {get}
//    var regular: String {get}
//}
//
//class BaseFont: ToDoFont {
//    static func == (lhs: BaseFont, rhs: BaseFont) -> Bool {
//        return lhs.bold == rhs.bold && lhs.semibold == rhs.semibold && lhs.regular == rhs.regular
//    }
//    
//    typealias StringLiteralType = String
//    
//    var bold = "Bold"
//    var semibold = "SemiBold"
//    var regular = "Regular"
//    
//}
//
//class CookieRunFont: BaseFont {
//
//    var bold: String = "CookieRunOTF-Bold"
//    var semibold: String = "CookieRunOTF-SemiBold"
//    var regular: String = "CookieRunOTF-Regular"
//}
//
//class WeMakePriceFont: ToDoFont {
//    static func == (lhs: WeMakePriceFont, rhs: WeMakePriceFont) -> Bool {
//        <#code#>
//    }
//    
//    typealias StringLiteralType = <#type#>
//    
//    var bold: String = "wemakepriceot-Bold"
//    var semibold: String = "wemakepriceot-SemiBold"
//    var regular: String = "wemakepriceot-regular"
//}
//
//class NanumGothicFont: ToDoFont {
//    var bold: String = "NanumBarunGothicOTFBold"
//    var semibold: String = "NanumBarunGothicOTF"
//    var regular: String = "NanumBarunGothicOTFLight"
//}
//
//enum ToDoFonts:  {
//    case CookieRun = Cooki
//}
