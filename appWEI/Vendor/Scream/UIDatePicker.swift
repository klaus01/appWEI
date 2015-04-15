//
//  UIDatePicker.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

extension UIDatePicker {
    
    public override func now(action: UIDatePicker -> ()) -> UIDatePicker {
        action(self)
        return self
    }
    
    public func dateChanged(label:String = "", action: (NSDate -> ())?) -> UIDatePicker {
        if action != nil {
            return self.__on(UIControlEvents.ValueChanged, label: label) { action!(($0 as! UIDatePicker).date ) } as! UIDatePicker
        } else {
            return self.__off(UIControlEvents.ValueChanged, label: label) as! UIDatePicker
        }
    }
}