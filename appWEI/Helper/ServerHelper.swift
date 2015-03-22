//
//  serverHelper.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

class ServerHelper {
    
    private class func appUserGet(parameters: [String: AnyObject], completionHandler: (AppUserModel?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/appUser/get", parameters: parameters).responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                completionHandler(AppUserModel(dic), error)
            }
        }
    }
    class func appUserGet(appUserID: Int, completionHandler: (AppUserModel?, NSError?) -> Void) {
        appUserGet(["appUserID": appUserID], completionHandler: completionHandler)
    }
    class func appUserGet(phoneNumber: String, completionHandler: (AppUserModel?, NSError?) -> Void) {
        appUserGet(["phoneNumber": phoneNumber], completionHandler: completionHandler)
    }
    
    class func appUserIsLogged(completionHandler: (Bool?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/appUser/isLogged").responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                completionHandler(dic["success"] as? Bool, error)
            }
        }
    }
    
}