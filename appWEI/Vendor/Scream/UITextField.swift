//
//  UITextField.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

public extension UITextField {
    
    public override func now(action: UITextField -> ()) -> UITextField {
        action(self)
        return self
    }
    
    public func textChanged(label:String = "", action: (String -> ())?) -> UITextField {
        if action != nil {
            return self.__on(UIControlEvents.EditingChanged | UIControlEvents.EditingDidBegin, label: label) { action!(($0 as! UITextField).text ) } as! UITextField
        } else {
            return self.__off(UIControlEvents.EditingChanged | UIControlEvents.EditingDidBegin, label: label) as! UITextField
        }
    }
}
