//
//  UserInfo.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import CoreLocation

private let sharedInstance = UserInfo()

class UserInfo: NSObject, CLLocationManagerDelegate {
    
    var id = 0
    var phoneNumber: String?
    var isLogged = false

    override init() {
        super.init()
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
    
    func startHeartbeat() {
        println("startHeartbeat")
        NSTimer.scheduledTimerWithTimeInterval(UPLOADLOCATION_INTERVAL, target: self, selector: "startHeartbeat", userInfo: nil, repeats: false)
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.first as! CLLocation
        println("didUpdateLocations: \(location.coordinate)")
        manager.stopUpdatingLocation()
        ServerHelper.appUserUpdateLocation(location.coordinate.longitude, location.coordinate.latitude) { (ret, error) -> Void in
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError: \(error)")
        manager.stopUpdatingLocation()
    }
}