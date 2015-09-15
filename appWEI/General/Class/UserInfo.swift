//
//  UserInfo.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


// 当前登录用户的朋友列表更新完成
public let kNotification_UpdatingFriends = "kNotification_UpdatingFriends"
public let kNotification_UpdateFriendsComplete = "kNotification_UpdateFriendsComplete"

// 当前登录用户的未读消息更新完成
public let kNotification_UpdatingUnreadMessages = "kNotification_UpdatingUnreadMessages"
public let kNotification_UpdateUnreadMessagesComplete = "kNotification_UpdateUnreadMessagesComplete"

// 当前登录用户创建了一个新字
public let kNotification_NewWord = "kNotification_NewWord"


class UserInfo: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var _sessionID: String? = nil
    private var _isLogged = false
    private var _deviceToken: String? = nil
    private var _isUpdatingFriends = false
    private var _isUpdatingUnreadMessages = false
    private var _lastUseWordIDs: [Int]!
    
    private func uploadDeviceToken() {
        if _isLogged && _deviceToken != nil {
            ServerHelper.appUserUpdateAPNSToken(_deviceToken!, completionHandler: { (ret, error) -> Void in
                if let error = error {
                    println(error)
                }
            })
        }
    }
    
    // MAKE: - Public
    
    var id = 0
    /// 用户手机号
    var phoneNumber: String?
    /// 昵称
    var nickname: String?
    /// 头像链接
    var iconUrl: String?
    // 用户是否已经登录
    var isLogged: Bool {
        get { return _isLogged }
        set {
            if _isLogged != newValue {
                _isLogged = newValue
                uploadDeviceToken()
            }
        }
    }
    // 远程通知令牌
    var deviceToken: String? {
        get { return _deviceToken }
        set {
            if _deviceToken != newValue {
                _deviceToken = newValue
                uploadDeviceToken()
            }
        }
    }
    var sessionID: String {
        return _sessionID!
    }
    
    // 用户的朋友列表，缓存
    var friends: [FriendModel] = [FriendModel]()
    var whitelistFriends: [FriendModel] {
        return friends.filter { (friend) -> Bool in
            return !friend.isBlack
        }
    }
    var blacklistFriends: [FriendModel] {
        return friends.filter { (friend) -> Bool in
            return friend.isBlack
        }
    }
    // 是否正在更新朋友列表
    var isUpdatingFriends: Bool { return _isUpdatingFriends }
    
    // 未读消息列表，缓存
    var unreadMessages: [HistoryMessageModel] = [HistoryMessageModel]()
    // 是否正在更新未读消息列表
    var isUpdatingUnreadMessages: Bool { return _isUpdatingUnreadMessages }
    
    // 最近使用的字ID列表
    var lastUseWordIDs: [Int] {
        return _lastUseWordIDs
    }
    func addLastUseWordID(id: Int) {
        _lastUseWordIDs.remove(id)
        _lastUseWordIDs.insert(id, atIndex: 0)
    }

    override init() {
        super.init()
        load()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    class var shared : UserInfo {
        return sharedInstance
    }
    
    func load() {
        let userDefaults = NSUserDefaults(suiteName: "UserInfo")!
        id               = userDefaults.integerForKey("id")
        phoneNumber      = userDefaults.stringForKey("phoneNumber")
        nickname         = userDefaults.stringForKey("nickname")
        iconUrl          = userDefaults.stringForKey("iconUrl")
        _isLogged        = userDefaults.boolForKey("isLogged")
        _deviceToken     = userDefaults.stringForKey("deviceToken")
        if let str = userDefaults.stringForKey("sessionID") {
            _sessionID = str
        }
        else {
            _sessionID = String.random(length: 64)
            userDefaults.setValue(_sessionID, forKey: "sessionID")
            userDefaults.synchronize()
        }
        if let array = userDefaults.arrayForKey("lastUseWordIDs") as? [Int] {
            _lastUseWordIDs = array
        }
        else {
            _lastUseWordIDs = [Int]()
        }
    }
    
    func save() {
        let userDefaults = NSUserDefaults(suiteName: "UserInfo")!
        userDefaults.setInteger(id, forKey: "id")
        userDefaults.setValue(phoneNumber, forKey: "phoneNumber")
        userDefaults.setValue(nickname, forKey: "nickname")
        userDefaults.setValue(iconUrl, forKey: "iconUrl")
        userDefaults.setBool(_isLogged, forKey: "isLogged")
        userDefaults.setValue(_deviceToken, forKey: "deviceToken")
        userDefaults.setObject(_lastUseWordIDs, forKey: "lastUseWordIDs")
        userDefaults.synchronize()
    }
    
    // 开始心跳，每隔一段时间获取一下经纬度上传到服务器
    func startHeartbeat() {
        if locationManager.respondsToSelector("requestAlwaysAuthorization") {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        let delta = NSEC_PER_SEC * UInt64(UPLOADLOCATION_INTERVAL)
        let afterTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delta))
        dispatch_after(afterTime, dispatch_get_main_queue()) { [weak self] () -> Void in
            if let weakSelf = self {
                self!.startHeartbeat()
            }
        }
    }
    
    // 更新用户的朋友列表
    func updateFriends() {
        if _isUpdatingFriends {
            return
        }
        
        _isUpdatingFriends = true
        NSNotificationCenter.defaultCenter().postNotificationName(kNotification_UpdatingFriends, object: nil)
        ServerHelper.appUserGetFriends { (ret, error) -> Void in
            self._isUpdatingFriends = false
            if let error = error {
                println(error)
            }
            else if ret!.success {
                self.friends = ret!.data!
                NSNotificationCenter.defaultCenter().postNotificationName(kNotification_UpdateFriendsComplete, object: nil)
            }
            else {
                println(ret!.errorMessage)
            }
        }
    }
    
    // 更新未读消息列表
    func updateUnreadMessages() {
        if _isUpdatingUnreadMessages {
            return
        }
        
        _isUpdatingUnreadMessages = true
        NSNotificationCenter.defaultCenter().postNotificationName(kNotification_UpdatingUnreadMessages, object: nil)
        ServerHelper.messageGetUnread { (ret, error) -> Void in
            self._isUpdatingUnreadMessages = false
            if let error = error {
                println(error)
            }
            else if ret!.success {
                self.unreadMessages = ret!.data!
                NSNotificationCenter.defaultCenter().postNotificationName(kNotification_UpdateUnreadMessagesComplete, object: nil)
            }
            else {
                println(ret!.errorMessage)
            }
        }
    }
    
    func removeUnreadMessage(messageID: Int) {
        let oldMessages = unreadMessages
        unreadMessages = oldMessages.filter() { (includeElement: HistoryMessageModel) -> Bool in
            return includeElement.message.id != messageID
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        manager.stopUpdatingLocation()
        let location = locations.first as! CLLocation
        ServerHelper.appUserUpdateLocation(location.coordinate.longitude, location.coordinate.latitude) { (ret, error) -> Void in
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
    }
}

private let sharedInstance = UserInfo()
