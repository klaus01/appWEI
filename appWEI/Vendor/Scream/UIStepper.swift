//
//  UIStepper.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

extension UIStepper {
    
    public override func now(action: UIStepper -> ()) -> UIStepper {
        action(self)
        return self
    }
    
    public func valueChanged(label:String = "", action: (Double -> ())?) -> UIStepper {
        if action != nil {
            return self.__on(UIControlEvents.ValueChanged, label: label) { action!(($0 as! UIStepper).value ) } as! UIStepper
        } else {
            return self.__off(UIControlEvents.ValueChanged, label: label) as! UIStepper
        }
    }
}