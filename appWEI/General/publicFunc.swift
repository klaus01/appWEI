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
    
    var length: Int {
        return self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
    
    /*
    * 匹配正则表达式
    * @param regularExpression 正则表达式
    * @return true:匹配 false:不匹配
    */
    func match(regularExpression: String) -> Bool {
        return self.rangeOfString(regularExpression, options: .RegularExpressionSearch) != nil
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
    if phoneNumber.match("^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$") {
        return .cn
    }
    else if phoneNumber.match("^(852|000852)?(5|6|9)[0-9]{7}$") {
        return .hk;
    }
    else {
        return .error;
    }
};