//
//  UIBarButtonItem.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

public extension UIBarButtonItem {
    
    public func now(action: UIBarButtonItem -> ()) -> UIBarButtonItem {
        action(self)
        return self
    }
    
    public func clicked(label:String = "", action: (UIBarButtonItem -> ())?) -> UIBarButtonItem {
        
        self.__offClicked(label:label)
        
        if action == nil {
            return self
        }
        
        let proxy = UIBarButtonItemProxy(action!)
        self.target = proxy
        self.action = "act:"
        self.proxies[label] = proxy

        return self
    }
}

///MARK:- Internal

private var UIBarButtonItemProxiesKey:Void

typealias UIBarButtonItemProxies = [String:UIBarButtonItemProxy]

internal class UIBarButtonItemProxy : NSObject {
    
    var action: UIBarButtonItem -> ()
    
    init(_ action: UIBarButtonItem -> ()) {
        self.action = action
    }
    
    func act(source: UIBarButtonItem) {
        action(source)
    }
}

internal extension UIBarButtonItem {
    
    func setter(newValue:UIBarButtonItemProxies) -> UIBarButtonItemProxies {
        objc_setAssociatedObject(self, &UIBarButtonItemProxiesKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
        return newValue
    }
    
    var proxies: UIBarButtonItemProxies {
        get {
            if let result = objc_getAssociatedObject(self, &UIBarButtonItemProxiesKey) as? UIBarButtonItemProxies {
                return result
            } else {
                return setter(UIBarButtonItemProxies())
            }
        }
        set {
            setter(newValue)
        }
    }
    
    func __offClicked(label:String = "") -> UIBarButtonItem {
        
        if let proxy = self.proxies[label] {
            self.target = nil
            self.action = ""
            self.proxies.removeValueForKey(label)
        }
        return self
    }
}