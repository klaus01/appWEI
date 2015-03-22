//
//  AppUserModel.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

struct AppUserModel {
    var appUserID: Int
    var phoneNumber: String
    var nickname: String
    var iconUrl: String
    var isMan: Bool
    var registrationStatus: Int
    
    init(_ userInfo: Dictionary<String, AnyObject>) {
        appUserID           = userInfo["AppUserID"] as Int
        phoneNumber         = userInfo["PhoneNumber"] as String
        nickname            = userInfo["Nickname"] as String
        iconUrl             = userInfo["IconUrl"] as String
        isMan               = userInfo["IsMan"] as Bool
        registrationStatus  = userInfo["RegistrationStatus"] as Int
    }
}