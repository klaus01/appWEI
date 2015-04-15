//
//  UIGestureRecognizer.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-15.
//  Copyright (c) 2014 Pinglin Tang. All rights reserved.
//

import UIKit

///MARK:- Public

public extension UIGestureRecognizer {

    convenience init(label:String = "", action: (UIGestureRecognizer) -> ()) {
        
        let proxy = UIGestureRecognizerProxy(action)
        self.init(target:proxy, action:"act:")
        self.__proxies[label] = proxy
    }
    
    public func on(label:String = "", action: ((UIGestureRecognizer) -> ())?) -> UIGestureRecognizer {
        self.__off(label:label)
        
        if action == nil {
            return self
        }
        
        let proxy = UIGestureRecognizerProxy(action!)
        self.__proxies[label] = proxy
        self.addTarget(proxy, action:"act:")
        
        return self
    }
    
    internal func __off(label:String = "") -> UIGestureRecognizer{
        
        if let proxy = self.__proxies[label] {
            self.removeTarget(proxy, action:"act:")
            self.__proxies.removeValueForKey(label)
        }
        
        return self
    }
}

///MARK:- Internal

private var __UIGestureRecognizerProxiesKey:Void

typealias __UIGestureRecognizerProxies = [String:UIGestureRecognizerProxy]

internal class UIGestureRecognizerProxy : NSObject {
    
    var action: UIGestureRecognizer -> ()
    
    init(_ action: UIGestureRecognizer -> ()) {
        self.action = action
    }
    
    func act(source: UIGestureRecognizer) {
        action(source)
    }
}

internal extension UIGestureRecognizer {
    
    func __proxyKey(event:UIControlEvents) -> String {
        return "UIGestureRecognizer:\(event.rawValue)"
    }
    
    func __setter(newValue:__UIGestureRecognizerProxies) -> __UIGestureRecognizerProxies {
        objc_setAssociatedObject(self, &__UIGestureRecognizerProxiesKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
        return newValue
    }
    
    var __proxies: __UIGestureRecognizerProxies {
        get {
            if let result = objc_getAssociatedObject(self, &__UIGestureRecognizerProxiesKey) as? __UIGestureRecognizerProxies {
                return result
            } else {
                return __setter(__UIGestureRecognizerProxies())
            }
        }
        set {
            __setter(newValue)
        }
    }
}