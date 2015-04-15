//
//  UISegmentedControl.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    public override func now(action: UISegmentedControl -> ()) -> UISegmentedControl {
        action(self)
        return self
    }

    public func selectedIndexChange(label:String = "", action: (Int -> ())?) -> UISegmentedControl {
        if action != nil {
            return self.__on(UIControlEvents.ValueChanged, label: label) { action!(($0 as! UISegmentedControl).selectedSegmentIndex ) } as! UISegmentedControl
        } else {
            return self.__off(UIControlEvents.ValueChanged, label: label) as! UISegmentedControl
        }
    }
}