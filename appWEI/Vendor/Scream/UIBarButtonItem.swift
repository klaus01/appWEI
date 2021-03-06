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
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, action: (UIBarButtonItem -> ())?) {
        
        let proxy = UIBarButtonItemProxy(action!)
        self.init(title: title, style: style, target: proxy, action: "act:")
        proxies[""] = proxy
    }
    
    public func clicked(label:String = "", action: (UIBarButtonItem -> ())?) -> UIBarButtonItem {
        
        self.__offClicked(label:label)
        
        if action == nil {
            return self
        }
        
        let proxy = UIBarButtonItemProxy(action!)
        self.target = proxy
        self.action = "act:"
        proxies[label] = proxy

        return self
    }
}

///MARK:- Internal

private var UIBarButtonItemProxiesKey: UInt8 = 0

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
        objc_setAssociatedObject(self, &UIBarButtonItemProxiesKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
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
            target = nil
            action = ""
            proxies.removeValueForKey(label)
        }
        return self
    }
}