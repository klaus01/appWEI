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

class UserInfo: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    private var _friends = [FriendModel]()
    private var _isUpdatingFriends = false
    
    var id = 0
    // 用户手机号
    var phoneNumber: String?
    // 用户是否已经登录
    var isLogged = false
    // 用户的朋友列表，缓存
    var friends: [FriendModel] {
        return _friends
    }
    // 是否正在更新朋友列表
    var isUpdatingFriends: Bool {
        return _isUpdatingFriends
    }

    override init() {
        locationManager = CLLocationManager()
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
        id             = userDefaults.integerForKey("id")
        phoneNumber    = userDefaults.stringForKey("phoneNumber")
        isLogged       = userDefaults.boolForKey("isLogged")
    }
    
    func save() {
        let userDefaults = NSUserDefaults(suiteName: "UserInfo")!
        userDefaults.setInteger(id, forKey: "id")
        userDefaults.setValue(phoneNumber, forKey: "phoneNumber")
        userDefaults.setBool(isLogged, forKey: "isLogged")
    }
    
    // 开始心跳，每隔一段时间获取一下经纬度上传到服务器
    func startHeartbeat() {
        NSTimer.scheduledTimerWithTimeInterval(UPLOADLOCATION_INTERVAL, target: self, selector: "startHeartbeat", userInfo: nil, repeats: false)
        
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
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
                self._friends = ret!.data!
                NSNotificationCenter.defaultCenter().postNotificationName(kNotification_UpdateFriendsComplete, object: nil)
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
