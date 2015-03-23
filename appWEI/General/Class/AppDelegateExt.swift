//
//  AppDelegateExt.swift
//  appWEI
//
//  Created by kelei on 15/3/23.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    
    class func shared() -> AppDelegate? {
        return UIApplication.sharedApplication().delegate as? AppDelegate
    }
    
}