//
//  UIControl.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

///MARK:- Public

public extension UIControl {
    
    public func now(action: UIControl -> ()) -> UIControl {
        action(self)
        return self
    }
    
    public func when(event:UIControlEvents, label:String = "", action: (UIControl -> ())?) -> UIControl {

        if action != nil {
            return self.__on(event, label: label, action: action!)
        } else {
            return self.__off(event, label: label)
        }
    }
}

///MARK:- Internal

private var __UIControlProxiesKey: UInt8 = 0

typealias __UIControlProxies = [String: [String: UIControlProxy]]

internal class UIControlProxy : NSObject {
    
    var action: UIControl -> ()
    
    init(_ action: UIControl -> ()) {
        self.action = action
    }
    
    func act(source: UIControl) {
        action(source)
    }
}

internal extension UIControl {
    
    func __proxyKey(event:UIControlEvents) -> String {
        return "UIControl:\(event.rawValue)"
    }
    
    func __setter(newValue:__UIControlProxies) -> __UIControlProxies {
        objc_setAssociatedObject(self, &__UIControlProxiesKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
        return newValue
    }
    
    var __proxies: __UIControlProxies {
        get {
            if let result = objc_getAssociatedObject(self, &__UIControlProxiesKey) as? __UIControlProxies {
                return result
            } else {
                return __setter(__UIControlProxies())
            }
        }
        set {
            __setter(newValue)
        }
    }
    
    func __on(event:UIControlEvents, label:String = "", action: UIControl -> ()) -> UIControl {
        self.__off(event, label:label)
        
        let proxy = UIControlProxy(action)
        self.addTarget(proxy, action: "act:", forControlEvents: event)
        
        let eventKey: String = __proxyKey(event)
        if __proxies[eventKey] == nil {
            __proxies[eventKey] = [String:UIControlProxy]()
        }
        
        __proxies[eventKey]![label] = proxy
        
        return self
    }
    
    func __off(event:UIControlEvents, label:String = "") -> UIControl {
        
        if let proxy: UIControlProxy = __proxies[__proxyKey(event)]?[label] {
            self.removeTarget(proxy, action: "act:", forControlEvents: event)
            __proxies[__proxyKey(event)]!.removeValueForKey(label)
        }
        return self
    }
}