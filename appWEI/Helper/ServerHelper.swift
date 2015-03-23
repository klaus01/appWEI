//
//  serverHelper.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

class ServerHelper {
    
    private class func getNoDataCompletionHandler(completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) -> (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void {
        func completionHandlerWithNoData(req: NSURLRequest, res: NSHTTPURLResponse?, JSON: AnyObject?, error: NSError?) -> Void {
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                completionHandler(ServerResultModel(dic), nil)
            }
        }
        return completionHandlerWithNoData
    }
    
    // MARK: - App用户类
    
    // 获取用户信息
    private class func appUserGet(parameters: [String: AnyObject], completionHandler: (ServerResultModel<AppUserModel>?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/appUser/get", parameters: parameters).responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                var data: AppUserModel?
                if let dic = dic["data"] as? Dictionary<String, AnyObject> {
                    data = AppUserModel(dic)
                }
                completionHandler(ServerResultModel(dic, data: data), nil)
            }
        }
    }
    class func appUserGet(appUserID: Int, completionHandler: (ServerResultModel<AppUserModel>?, NSError?) -> Void) {
        appUserGet(["appUserID": appUserID], completionHandler: completionHandler)
    }
    class func appUserGet(phoneNumber: String, completionHandler: (ServerResultModel<AppUserModel>?, NSError?) -> Void) {
        appUserGet(["phoneNumber": phoneNumber], completionHandler: completionHandler)
    }
    
    // 获取用户朋友列表
    class func appUserGetFriends(completionHandler: (ServerResultModel<[FriendModel]>?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/appUser/getFriends").responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                var data = [FriendModel]()
                if let arr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                    for dic in arr {
                        data.append(FriendModel(dic))
                    }
                }
                completionHandler(ServerResultModel(dic, data: data), nil)
            }
        }
    }
    
    // 获取用户是否已登录
    class func appUserIsLogged(completionHandler: (Bool?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/appUser/isLogged").responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                completionHandler(dic["success"] as? Bool, nil)
            }
        }
    }
    
    // 用户注册
    class func appUserRegisterAndSendCheck(phoneNumber: String, device: String, deviceOS: String, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "phoneNumber": phoneNumber,
            "device": device,
            "deviceOS": deviceOS
        ]
        request(.GET, "\(SERVER_HOST)/appUser/registerAndSendCheck", parameters: parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    // 修改用户资料
    class func appUserUpdate(iconFile: NSData, nickname: String, isMan: Bool, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "iconFile": UploadValue.PNGFILE(iconFile),
            "nickname": UploadValue.STRING(nickname),
            "isMan": UploadValue.STRING(isMan ? "1" : "0")
        ]
        upload("\(SERVER_HOST)/appUser/update", parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    // 提交APNS令牌
    class func appUserUpdateAPNSToken(token: String, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "APNSToken": token
        ]
        request(.GET, "\(SERVER_HOST)/appUser/updateAPNSToken", parameters: parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    // 更新用户状态为 已进入应用主页
    class func appUserEnterHome(completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/appUser/enterHome").responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    // 更新地理位置信息
    class func appUserUpdateLocation(longitude: Double, latitude: Double, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "longitude": longitude,
            "latitude": latitude
        ]
        request(.GET, "\(SERVER_HOST)/appUser/updateLocation", parameters: parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    // 添加或邀请朋友
    class func appUserAddFriend(phoneNumber: String, completionHandler: (ServerResultModel<SimpleMessageModel>?, NSError?) -> Void) {
        let parameters = [
            "phoneNumber": phoneNumber
        ]
        request(.GET, "\(SERVER_HOST)/appUser/addFriend", parameters: parameters).responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                var data: SimpleMessageModel?
                if let dic = dic["data"] as? Dictionary<String, AnyObject> {
                    data = SimpleMessageModel(dic)
                }
                completionHandler(ServerResultModel(dic, data: data), nil)
            }
        }
    }
    
    // 订阅公众号
    class func appUserAddPartnerUser(partnerUserID: Int, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "partnerUserID": partnerUserID
        ]
        request(.GET, "\(SERVER_HOST)/appUser/addPartnerUser", parameters: parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    // 设置朋友是否在黑名单中
    class func appUserSetFriendIsBlack(friendUserID: Int, isBlack: Bool, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "friendUserID": friendUserID,
            "isBlack": isBlack.hashValue
        ]
        request(.GET, "\(SERVER_HOST)/appUser/setFriendIsBlack", parameters: parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
    
    // MARK: - 消息相关
    // 获取未读消息列表
    class func messageGetUnread(completionHandler: (ServerResultModel<[UnreadMessageModel]>?, NSError?) -> Void) {
        request(.GET, "\(SERVER_HOST)/message/getUnread").responseJSON { (req, res, JSON, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                var data = [UnreadMessageModel]()
                if let arr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                    for dic in arr {
                        data.append(UnreadMessageModel(dic))
                    }
                }
                completionHandler(ServerResultModel(dic, data: data), nil)
            }
        }
    }
    
    // 设置消息已读
    class func messageSetRead(messageID: Int, completionHandler: (ServerResultModel<Void>?, NSError?) -> Void) {
        let parameters = [
            "messageID": messageID
        ]
        request(.GET, "\(SERVER_HOST)/message/setRead", parameters: parameters).responseJSON(getNoDataCompletionHandler(completionHandler))
    }
    
}