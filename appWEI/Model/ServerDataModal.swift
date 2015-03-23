//
//  ServerDataModal.swift
//  appWEI
//
//  Created by kelei on 15/3/23.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

// MARK: - 返回信息
struct ServerResultModel<T> {
    let success: Bool
    let errorMessage: String?
    let data: T?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        success      = dic["success"] as Bool
        errorMessage = dic["message"] as? String
    }
    init(_ dic: Dictionary<String, AnyObject>, data: T?) {
        success      = dic["success"] as Bool
        errorMessage = dic["message"] as? String
        self.data    = data
    }
}

// MARK: - 应用用户信息
struct AppUserModel {
    let appUserID: Int
    let phoneNumber: String
    let nickname: String?
    let iconUrl: String?
    let isMan: Bool?
    let registrationStatus: Int
    
    init(_ dic: Dictionary<String, AnyObject>) {
        appUserID           = dic["AppUserID"] as Int
        phoneNumber         = dic["PhoneNumber"] as String
        nickname            = dic["Nickname"] as? String
        iconUrl             = dic["IconUrl"] as? String
        isMan               = dic["IsMan"] as? Bool
        registrationStatus  = dic["RegistrationStatus"] as Int
    }
}

// MARK: - 公众号用户信息
struct PartnerUserModel {
    let partnerUserID: Int
    let name: String
    let iconUrl: String
    let description: String?
    let createTime: Date
    
    init(_ dic: Dictionary<String, AnyObject>) {
        partnerUserID = dic["PartnerUserID"] as Int
        name          = dic["Name"] as String
        iconUrl       = dic["IconUrl"] as String
        description   = dic["Description"] as? String
        createTime    = Date(dic["CreateTime"] as String)
    }
}

// MARK: - 朋友信息
struct FriendModel {
    let appUser: AppUserModel?
    let partnerUser: PartnerUserModel?
    let unreadCount: Int?
    let lastTime: Date?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        if let dic = dic["AppUser"] as? Dictionary<String, AnyObject> {
            appUser = AppUserModel(dic)
        }
        if let dic = dic["PartnerUser"] as? Dictionary<String, AnyObject> {
            partnerUser = PartnerUserModel(dic)
        }
        if let time = dic["LastTime"] as? String {
            lastTime = Date(time)
        }
        unreadCount = dic["UnreadCount"] as? Int
    }
}

// MARK: - 信息
struct MessageModel {
    let message: String
    
    init(_ dic: Dictionary<String, AnyObject>) {
        message = dic["message"] as String
    }
}