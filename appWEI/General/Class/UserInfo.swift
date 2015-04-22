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
public let kNotification_UpdateFriendsComplete = "kNotification_UpdateFriendsComplete"

// 当前登录用户的未读消息更新完成
public let kNotification_UpdateUnreadMessagesComplete = "kNotification_UpdateUnreadMessagesComplete"


class UserInfo: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var _isLogged = false
    private var _deviceToken: String? = nil
    private var _isUpdatingFriends = false
    private var _isUpdatingUnreadMessages = false
    
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
    // 用户手机号
    var phoneNumber: String?
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
    var unreadMessages: [UnreadMessageModel] = [UnreadMessageModel]()
    // 是否正在更新未读消息列表
    var isUpdatingUnreadMessages: Bool { return _isUpdatingUnreadMessages }

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
        _isLogged        = userDefaults.boolForKey("isLogged")
        _deviceToken     = userDefaults.stringForKey("deviceToken")
    }
    
    func save() {
        let userDefaults = NSUserDefaults(suiteName: "UserInfo")!
        userDefaults.setInteger(id, forKey: "id")
        userDefaults.setValue(phoneNumber, forKey: "phoneNumber")
        userDefaults.setBool(_isLogged, forKey: "isLogged")
        userDefaults.setValue(_deviceToken, forKey: "deviceToken")
    }
    
    // 开始心跳，每隔一段时间获取一下经纬度上传到服务器
    func startHeartbeat() {
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        let delta = NSEC_PER_SEC * UInt64(UPLOADLOCATION_INTERVAL)
        let afterTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delta))
        dispatch_after(afterTime, dispatch_get_main_queue()) { () -> Void in
            self.startHeartbeat()
        }
    }
    
    // 更新用户的朋友列表
    func updateFriends() {
        if _isUpdatingFriends {
            return
        }
        
        _isUpdatingFriends = true
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
