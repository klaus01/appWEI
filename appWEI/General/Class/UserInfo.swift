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

private let sharedInstance = UserInfo()

class UserInfo: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    var id = 0
    var phoneNumber: String?
    var isLogged = false

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
    
    func startHeartbeat() {
        NSTimer.scheduledTimerWithTimeInterval(UPLOADLOCATION_INTERVAL, target: self, selector: "startHeartbeat", userInfo: nil, repeats: false)
        
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
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