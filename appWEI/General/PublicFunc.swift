//
//  publicFunc.swift
//  appWEI
//
//  Created by kelei on 15/3/24.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import Foundation

extension String {
    
    /*
    * 匹配正则表达式
    * @param target 需要替换的字符串
    * @param withString 替换为新的字符串
    * @return 替换后的字符串
    */
    func replace(target: String, withString: String) -> String
    {
        return (self as NSString).stringByReplacingOccurrencesOfString(target, withString: withString)
//        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /*
    * 匹配正则表达式
    * @param regularExpression 正则表达式
    * @return true:匹配 false:不匹配
    */
    func match(regularExpression: String) -> Bool {
        return self.rangeOfString(regularExpression, options: .RegularExpressionSearch) != nil
    }
    
    func getPinYin() -> String {
        var cn = NSMutableString(string: self) as CFMutableStringRef
        CFStringTransform(cn, nil, kCFStringTransformMandarinLatin, Boolean(0))
        return cn as String
    }
    
}

extension UIAlertView {
    
    class func showMessage(message: String, cancelButtonTitle: String? = "知道了") {
        UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
    }
    
}

/**
* 根据手机号返回区域类型
* @param phoneNumber 手机号
* @return PhoneNumberAreaType
*/
enum PhoneNumberAreaType: Int {
    case error = -1
    case cn = 0
    case hk = 1
}
func getPhoneNumberAreaType(phoneNumber: String) -> PhoneNumberAreaType {
    if phoneNumber =~ "^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$" {
        return .cn
    }
    else if phoneNumber =~ "^(852|000852)?(5|6|9)[0-9]{7}$" {
        return .hk;
    }
    else {
        return .error;
    }
};

/**
* 获取当前应用的Library/Caches目录
*/
func getCachesDirectory() -> String {
    return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}