//
//  serverHelper.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

class ServerHelper {
    
    struct Static {
        // 静态的目的是只调用UUIDString一次。
        static let SessionID = UUIDString
    }
    
    private class func getCompletionHandlerWithNoData(completionHandler: (ServerResultModel<Any>?, NSError?) -> Void) -> (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void {
        func completionHandler(req: NSURLRequest, res: NSHTTPURLResponse?, JSON: AnyObject?, error: NSError?) -> Void {
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                completionHandler(ServerResultModel(dic), nil)
            }
        }
        return completionHandler
    }
    
    private class func getCompletionHandlerWithObject<T: ServerDataProtocol>(completionHandler: (ServerResultModel<T>?, NSError?) -> Void) -> (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void {
        func completionHandler(req: NSURLRequest, res: NSHTTPURLResponse?, JSON: AnyObject?, error: NSError?) -> Void {
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                var data: T?
                if let dic = dic["data"] as? Dictionary<String, AnyObject> {
                    data = T(dic)
                }
                completionHandler(ServerResultModel(dic, data: data), nil)
            }
        }
        return completionHandler
    }
    
    private class func getCompletionHandlerWithArray<T: ServerDataProtocol>(completionHandler: (ServerResultModel<[T]>?, NSError?) -> Void) -> (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void {
        func completionHandler(req: NSURLRequest, res: NSHTTPURLResponse?, JSON: AnyObject?, error: NSError?) -> Void {
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let dic = JSON as? Dictionary<String, AnyObject> {
                var data = [T]()
                if let arr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                    for dic in arr {
                        data.append(T(dic))
                    }
                }
                completionHandler(ServerResultModel(dic, data: data), nil)
            }
        }
        return completionHandler
    }
    
    private class func myRequest(urlPathName: String, parameters: [String: AnyObject]? = nil) -> Request {
        var param: [String: AnyObject]!
        if let p = parameters {
            param = p
        }
        else {
            param = [String: AnyObject]()
        }
        param["sessionID"] = Static.SessionID
        return request(.GET, "\(SERVER_HOST_INTERFACE)\(urlPathName)", parameters: param)
    }
    
    private class func myUpload(urlPathName: String, _ parameters: [String: UploadValue]? = nil) -> Request {
        var param: [String: UploadValue]!
        if let p = parameters {
            param = p
        }
        else {
            param = [String: UploadValue]()
        }
        param["sessionID"] = UploadValue.STRING(Static.SessionID)
        return upload("\(SERVER_HOST_INTERFACE)\(urlPathName)", param)
    }
    
    // MARK: - App用户类
    // 获取用户信息
    class func appUserGet(appUserID: Int, completionHandler: (ret: ServerResultModel<AppUserModel>?, error: NSError?) -> Void) {
        myRequest("/appUser/get", parameters: ["appUserID": appUserID]).responseJSON(getCompletionHandlerWithObject(completionHandler))
    }
    class func appUserGet(phoneNumber: String, completionHandler: (ret: ServerResultModel<AppUserModel>?, error: NSError?) -> Void) {
        myRequest("/appUser/get", parameters: ["phoneNumber": phoneNumber]).responseJSON(getCompletionHandlerWithObject(completionHandler))
    }
    
    // 获取用户朋友列表
    class func appUserGetFriends(completionHandler: (ret: ServerResultModel<[FriendModel]>?, error: NSError?) -> Void) {
        myRequest("/appUser/getFriends").responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    // 获取用户是否已登录
    class func appUserIsLogged(completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/appUser/isLogged").responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    // 用户注册
    class func appUserRegisterAndSendCheck(phoneNumber: String, device: String, deviceOS: String, completionHandler: (ret: ServerResultModel<AppUserRegisterModel>?, error: NSError?) -> Void) {
        myRequest("/appUser/registerAndSendCheck", parameters: [
            "phoneNumber": phoneNumber,
            "device": device,
            "deviceOS": deviceOS
            ]).responseJSON(getCompletionHandlerWithObject(completionHandler))
    }
    
    // 修改用户资料
    class func appUserUpdate(iconFile: NSData, nickname: String, isMan: Bool, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myUpload("/appUser/update", [
            "iconFile": UploadValue.PNGFILE(iconFile),
            "nickname": UploadValue.STRING(nickname),
            "isMan": UploadValue.STRING(isMan ? "1" : "0")
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    // 提交APNS令牌
    class func appUserUpdateAPNSToken(token: String, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/appUser/updateAPNSToken", parameters: [
            "APNSToken": token
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    // 更新用户状态为 已进入应用主页
    class func appUserEnterHome(completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/appUser/enterHome").responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    // 更新地理位置信息
    class func appUserUpdateLocation(longitude: Double, _ latitude: Double, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/appUser/updateLocation", parameters: [
            "longitude": longitude,
            "latitude": latitude
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    // 添加或邀请朋友
    class func appUserAddFriend(phoneNumber: String, completionHandler: (ret: ServerResultModel<SimpleMessageModel>?, error: NSError?) -> Void) {
        myRequest("/appUser/addFriend", parameters: [
            "phoneNumber": phoneNumber
            ]).responseJSON(getCompletionHandlerWithObject(completionHandler))
    }
    
    // 订阅公众号
    class func appUserAddPartnerUser(partnerUserID: Int, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/appUser/addPartnerUser", parameters: [
            "partnerUserID": partnerUserID
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    // 设置朋友是否在黑名单中
    class func appUserSetFriendsIsBlack(friendUserIDs: [Int], isBlack: Bool, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/appUser/setFriendsIsBlack", parameters: [
            "friendUserIDs": friendUserIDs,
            "isBlack": isBlack.hashValue
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    
    // MARK: - 消息相关
    // 获取未读消息列表
    class func messageGetUnread(completionHandler: (ret: ServerResultModel<[HistoryMessageModel]>?, error: NSError?) -> Void) {
        myRequest("/message/getUnread").responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    // 获取用户与公众号历史消息列表
    class func messageGetByPartnerUser(partnerUserID: Int, completionHandler: (ret: ServerResultModel<[HistoryMessageModel]>?, error: NSError?) -> Void) {
        myRequest("/message/getByPartnerUser", parameters: [
            "partnerUserID": partnerUserID
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    // 设置消息已读
    class func messageSetRead(messageID: Int, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/message/setRead", parameters: [
            "messageID": messageID
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    
    // MARK: - 公众号相关
    // 获取可订阅的公众号列表
    class func partnerUserGetCanSubscribe(completionHandler: (ret: ServerResultModel<[PartnerUserModel]>?, error: NSError?) -> Void) {
        myRequest("/partnerUser/getCanSubscribe").responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    // 获取用户已订阅的公众号列表
    class func partnerUserGetSubscribed(completionHandler: (ret: ServerResultModel<[PartnerUserAndMessageOverviewModel]>?, error: NSError?) -> Void) {
        myRequest("/partnerUser/getSubscribed").responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    
    // MARK: - 短信相关
    // 获取可订阅的公众号列表
    class func smsCheckVerificationCode(phoneNumber: String, verificationCode: String, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/sms/checkVerificationCode", parameters: [
            "phoneNumber": phoneNumber,
            "verificationCode": verificationCode
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
    
    
    // MARK: - 字相关
    /*
    * 获取字列表
    * @param orderByType: 0按UseCount_Before1D排序，1按UseCount_Before30D排序，2按UseCount_Before365D排序
    * @param [number or description]
    * @param [offset, resultCount]
    * @returns {[word]} 按UseCount降序
    */
    class func wordFindAll(orderByType: Int, offset: Int, resultCount: Int, completionHandler: (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void) {
        myRequest("/word/findAll", parameters: [
            "orderByType": orderByType,
            "offset": offset,
            "resultCount": resultCount
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    class func wordFindAll(orderByType: Int, number: String, offset: Int, resultCount: Int, completionHandler: (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void) {
        myRequest("/word/findAll", parameters: [
            "orderByType": orderByType,
            "offset": offset,
            "resultCount": resultCount,
            "number": number
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    class func wordFindAll(orderByType: Int, description: String, offset: Int, resultCount: Int, completionHandler: (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void) {
        myRequest("/word/findAll", parameters: [
            "orderByType": orderByType,
            "offset": offset,
            "resultCount": resultCount,
            "description": description
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    /*
    * 获取用户可看到的字列表
    * @param [number or description]
    * @param [offset, resultCount]
    * @returns {[word]} 按Number升序 返回系统字、appUser发送的字 和 appUser接收到的字
    */
    class func wordFindByAppUser(#offset: Int, resultCount: Int, completionHandler: (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void) {
        myRequest("/word/findByAppUser", parameters: [
            "offset": offset,
            "resultCount": resultCount
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    class func wordFindByAppUser(#number: String, offset: Int, resultCount: Int, completionHandler: (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void) {
        myRequest("/word/findByAppUser", parameters: [
            "offset": offset,
            "resultCount": resultCount,
            "number": number
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    class func wordFindByAppUser(#description: String, offset: Int, resultCount: Int, completionHandler: (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void) {
        myRequest("/word/findByAppUser", parameters: [
            "offset": offset,
            "resultCount": resultCount,
            "description": description
            ]).responseJSON(getCompletionHandlerWithArray(completionHandler))
    }
    
    // 创建字
    class func wordNew(description: String, pictureFile: NSData, audioFile: NSData?, completionHandler: (ret: ServerResultModel<NewWordModel>?, error: NSError?) -> Void) {
        var parameters = [
            "description": UploadValue.STRING(description),
            "pictureFile": UploadValue.PNGFILE(pictureFile)
        ]
        if let audioFile = audioFile {
            parameters["audioFile"] = UploadValue.OTHERFILE(audioFile, "mp3")
        }
        myUpload("/word/new", parameters).responseJSON(getCompletionHandlerWithObject(completionHandler))
    }
    
    // 发送字
    class func wordSend(wordID: Int, friendsUsers: Array<Int>, completionHandler: (ret: ServerResultModel<Any>?, error: NSError?) -> Void) {
        myRequest("/word/send", parameters: [
            "wordID": wordID,
            "friendsUserID": friendsUsers
            ]).responseJSON(getCompletionHandlerWithNoData(completionHandler))
    }
}