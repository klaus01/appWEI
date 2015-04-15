//
//  UISlider.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

extension UISlider {
    
    public override func now(action: UISlider -> ()) -> UISlider {
        action(self)
        return self
    }
    
    public func valueChanged(label:String = "", action: (Float -> ())?) -> UISlider {
        if action != nil {
            return self.__on(UIControlEvents.ValueChanged, label: label) { action!(($0 as! UISlider).value ) } as! UISlider
        } else {
            return self.__off(UIControlEvents.ValueChanged, label: label) as! UISlider
        }
    }
}