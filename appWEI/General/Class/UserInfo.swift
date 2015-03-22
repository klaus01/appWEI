//
//  UserInfo.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

private let sharedInstance = UserInfo()

class UserInfo  {
    
    var id = 0
    var phoneNumber: String?
    var isLogged = false
    
    init() {
        self.load()
    }
    
    class var shared : UserInfo {
        return sharedInstance
    }
    
    func load() {
        let userDefaults = NSUserDefaults(suiteName: "UserInfo")!
        self.id             = userDefaults.integerForKey("id")
        self.phoneNumber    = userDefaults.stringForKey("phoneNumber")
        self.isLogged       = userDefaults.boolForKey("isLogged")
    }
    
    func save() {
        let userDefaults = NSUserDefaults(suiteName: "UserInfo")!
        userDefaults.setInteger(self.id, forKey: "id")
        userDefaults.setValue(self.phoneNumber, forKey: "phoneNumber")
        userDefaults.setBool(self.isLogged, forKey: "isLogged")
    }
    
}