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
    
    /**
    替换字符串
    
    :param: target     需要替换的字符串
    :param: withString 替换为新的字符串
    
    :returns: 替换后的字符串
    */
    func replace(target: String, withString: String) -> String
    {
        return (self as NSString).stringByReplacingOccurrencesOfString(target, withString: withString)
    }
    
    /**
    匹配正则表达式
    
    :param: regularExpression 正则表达式
    
    :returns: true:匹配 false:不匹配
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
    
    /**
    显示提示对话框
    
    :param: message           提示文字
    :param: cancelButtonTitle 按钮文字
    :param: didDismiss        点击按钮后的回调
    */
    class func showMessage(message: String, cancelButtonTitle: String = "知道了", didDismiss: (() -> Void)? = nil) {
        UIAlertView(title: nil, message: message, cancelButtonTitle: cancelButtonTitle)
            .didDismiss { (buttonAtIndex) -> () in
                if let f = didDismiss { f() }
            }
            .show()
    }
    
    /**
    显示询问对话框
    
    :param: message        提示文字
    :param: yesButtonTitle yes按钮名称
    :param: noButtonTitle  no按钮名称
    :param: didDismiss     点击按钮后的回调(isYes: true点击的yes按钮 false点击的no按钮)
    */
    class func yesOrNo(message: String, yesButtonTitle: String = "是", noButtonTitle: String = "否", didDismiss: ((isYes: Bool) -> Void)? = nil) {
        UIAlertView(title: message, message: "", cancelButtonTitle: yesButtonTitle, otherButtonTitles: noButtonTitle)
            .didDismiss { (buttonAtIndex) -> () in
                if let f = didDismiss {
                    f(isYes: buttonAtIndex == 0)
                }
            }
            .show()
    }
    
}

enum PhoneNumberAreaType: Int {
    case error = -1
    case cn = 0
    case hk = 1
}
/**
根据手机号返回区域类型

:param: phoneNumber 手机号

:returns: PhoneNumberAreaType
*/
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
获取当前应用的Library/Caches目录

:returns: 目录字符串
*/
func getCachesDirectory() -> String {
    return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}