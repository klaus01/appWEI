//
//  UIRefreshControl.swift
//  Scream
//
//  Created by Pinglin Tang on 14/10/18.
//  Copyright (c) 2014 Pinglin Tang All rights reserved.
//

import UIKit

public extension UIRefreshControl {
    
    public override func now(action: UIRefreshControl -> ()) -> UIRefreshControl {
        action(self)
        return self
    }
    
    public func pulled(label:String = "", action: (() -> ())?) -> UIRefreshControl {
        if action != nil {
            return self.__on(UIControlEvents.ValueChanged, label: label) { control in action!() } as! UIRefreshControl
        } else {
            return self.__off(UIControlEvents.ValueChanged, label: label) as! UIRefreshControl
        }
    }
}