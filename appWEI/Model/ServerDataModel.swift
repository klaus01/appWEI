//
//  ServerDataModal.swift
//  appWEI
//
//  Created by kelei on 15/3/23.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

protocol ServerDataProtocol {
    init(_ dic: Dictionary<String, AnyObject>)
}

// 返回信息
struct ServerResultModel<T> : ServerDataProtocol {
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

// 简单文字信息
struct SimpleMessageModel : ServerDataProtocol {
    let message: String
    
    init(_ dic: Dictionary<String, AnyObject>) {
        message = dic["message"] as String
    }
}

// 应用用户
struct AppUserModel : ServerDataProtocol {
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

// 应用用户注册
struct AppUserRegisterModel : ServerDataProtocol {
    let appUserID: Int
    let smsID: Int
    
    init(_ dic: Dictionary<String, AnyObject>) {
        appUserID = dic["appUserID"] as Int
        smsID     = dic["smsID"] as Int
    }
}

// 公众号用户
struct PartnerUserModel : ServerDataProtocol {
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

// 朋友
struct FriendModel : ServerDataProtocol {
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

// 消息
struct MessageModel : ServerDataProtocol {
    let id: Int
    let createTime: Date
    let sourceUserID: Int
    let receiveUserID: Int
    let type: Int
    let content: String
    let isRead: Bool
    
    init(_ dic: Dictionary<String, AnyObject>) {
        id              = dic["ID"] as Int
        createTime      = Date(dic["CreateTime"] as String)
        sourceUserID    = dic["SourceUserID"] as Int
        receiveUserID   = dic["ReceiveUserID"] as Int
        type            = dic["Type"] as Int
        content         = dic["Content"] as String
        isRead          = dic["IsRead"] as Bool
    }
}

// 字
struct WordModel : ServerDataProtocol {
    let id: Int
    let number: String
    let createUserID: Int?
    let pictureUrl: String
    let description: String?
    let audioUrl: String?
    let useCount_Before1D_CN: Int
    let useCount_Before30D_CN: Int
    let useCount_Before365D_CN: Int
    let useCount_Before1D_HK: Int
    let useCount_Before30D_HK: Int
    let useCount_Before365D_HK: Int
    
    init(_ dic: Dictionary<String, AnyObject>) {
        id                      = dic["ID"] as Int
        number                  = dic["Number"] as String
        createUserID            = dic["CreateUserID"] as? Int
        pictureUrl              = dic["PictureUrl"] as String
        description             = dic["Description"] as? String
        audioUrl                = dic["AudioUrl"] as? String
        useCount_Before1D_CN    = dic["UseCount_Before1D_CN"] as Int
        useCount_Before30D_CN   = dic["UseCount_Before30D_CN"] as Int
        useCount_Before365D_CN  = dic["UseCount_Before365D_CN"] as Int
        useCount_Before1D_HK    = dic["UseCount_Before1D_HK"] as Int
        useCount_Before30D_HK   = dic["UseCount_Before30D_HK"] as Int
        useCount_Before365D_HK  = dic["UseCount_Before365D_HK"] as Int
    }
}

// 创建字的返回结构
struct NewWordModel : ServerDataProtocol {
    let newWordID: Int
    
    init(_ dic: Dictionary<String, AnyObject>) {
        newWordID = dic["newWordID"] as Int
    }
}

// 活动
struct ActivityModel : ServerDataProtocol {
    let id: Int
    let partnerUserID: Int
    let createTime: Date
    let mode: Int
    let pictureUrl: String
    let content: String
    let url: String?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        id              = dic["ID"] as Int
        partnerUserID   = dic["PartnerUserID"] as Int
        createTime      = Date(dic["CreateTime"] as String)
        mode            = dic["Mode"] as Int
        pictureUrl      = dic["PictureUrl"] as String
        content         = dic["Content"] as String
        url             = dic["Url"] as? String
    }
}

// 中奖信息
struct GiftModel : ServerDataProtocol {
    let partnerActivityID: Int
    let appUserID: Int
    let awardQRCodeInfo: String
    let awardTime: Date?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        partnerActivityID   = dic["PartnerActivityID"] as Int
        appUserID           = dic["AppUserID"] as Int
        awardQRCodeInfo     = dic["AwardQRCodeInfo"] as String
        if let time = dic["AwardTime"] as? String {
            awardTime       = Date(time)
        }
    }
}

// 未读消息
struct UnreadMessageModel : ServerDataProtocol {
    let message: MessageModel
    let appUser: AppUserModel?
    let partnerUser: PartnerUserModel?
    let word: WordModel?
    let activity: ActivityModel?
    let gift: GiftModel?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        message = MessageModel(dic["Message"] as Dictionary<String, AnyObject>)
        if let dic = dic["AppUser"] as? Dictionary<String, AnyObject> {
            appUser = AppUserModel(dic)
        }
        if let dic = dic["PartnerUser"] as? Dictionary<String, AnyObject> {
            partnerUser = PartnerUserModel(dic)
        }
        if let dic = dic["Word"] as? Dictionary<String, AnyObject> {
            word = WordModel(dic)
        }
        if let dic = dic["Activity"] as? Dictionary<String, AnyObject> {
            activity = ActivityModel(dic)
        }
        if let dic = dic["Gift"] as? Dictionary<String, AnyObject> {
            gift = GiftModel(dic)
        }
    }
}

// 历史消息
struct HistoryMessageModel : ServerDataProtocol {
    let message: MessageModel
    let word: WordModel?
    let activity: ActivityModel?
    let gift: GiftModel?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        message = MessageModel(dic["Message"] as Dictionary<String, AnyObject>)
        if let dic = dic["Word"] as? Dictionary<String, AnyObject> {
            word = WordModel(dic)
        }
        if let dic = dic["Activity"] as? Dictionary<String, AnyObject> {
            activity = ActivityModel(dic)
        }
        if let dic = dic["Gift"] as? Dictionary<String, AnyObject> {
            gift = GiftModel(dic)
        }
    }
}

// 公众号消息情况
struct PartnerUserMessageOverviewModel : ServerDataProtocol {
    let lastTime: Date
    let unreadCount: Int
    let noAwardCount: Int
    
    init(_ dic: Dictionary<String, AnyObject>) {
        lastTime        = Date(dic["LastTime"] as String)
        unreadCount     = dic["UnreadCount"] as Int
        noAwardCount    = dic["noAwardCount"] as Int
    }
}

// 公众号带消息
struct PartnerUserAndMessageOverviewModel : ServerDataProtocol {
    let partnerUser: PartnerUserModel
    let messageOverview: PartnerUserMessageOverviewModel?
    
    init(_ dic: Dictionary<String, AnyObject>) {
        partnerUser = PartnerUserModel(dic["PartnerUser"] as Dictionary<String, AnyObject>)
        if let dic = dic["MessageOverview"] as? Dictionary<String, AnyObject> {
            messageOverview = PartnerUserMessageOverviewModel(dic)
        }
    }
}