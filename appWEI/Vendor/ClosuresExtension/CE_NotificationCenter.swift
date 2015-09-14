//
//  CE_NotificationCenter.swift
//  appWEI
//
//  Created by kelei on 15/4/19.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

extension NSObject {
    
    private var ce: NSObject_Delegate {
        struct Static {
            static var AssociationKey: UInt8 = 0
        }
        if let obj = objc_getAssociatedObject(self, &Static.AssociationKey) as? NSObject_Delegate {
            return obj
        }
        let delegate = NSObject_Delegate()
        objc_setAssociatedObject(self, &Static.AssociationKey, delegate, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        return delegate
    }

    public func ce_addObserverForName(name: String, handle: (notification: NSNotification) -> Void) -> Self {
        ce.addNotificationForName(name, handle: handle)
        NSNotificationCenter.defaultCenter().addObserver(ce, selector: "observerHandlerAction:", name: name, object: nil)
        return self
    }
    
    public func ce_removeObserverForName(name: String) -> Self {
        NSNotificationCenter.defaultCenter().removeObserver(ce, name: name, object: nil)
        return self
    }
    
    public func ce_removeObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(ce)
    }
    
}

private class NSObject_Delegate: NSObject {
    
    #if DEBUG
    override init() {
        super.init()
        println("init \(self)")
    }
    deinit {
        println("deinit \(self)")
    }
    #endif
    
    typealias NotificationAction = (NSNotification) -> Void
    private var dic = [String : NotificationAction]()
    
    func addNotificationForName(name: String, handle: (notification: NSNotification) -> Void) {
        dic[name] = handle
    }
    
    @objc func observerHandlerAction(notification: NSNotification) {
        if let action = dic[notification.name] {
            action(notification)
        }
    }

}