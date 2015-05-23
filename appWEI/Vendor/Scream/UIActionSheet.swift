//
//  UIActionSheet.swift
//  Scream
//
//  Created by Pinglin Tang on 14-10-17.
//  Copyright (c) 2014 Scream. All rights reserved.
//

import UIKit

public extension UIActionSheet {
    
    public func now(action: UIActionSheet -> ()) -> UIActionSheet {
        action(self)
        return self
    }

    public convenience init(title: String?, cancelButtonTitle: String?, destructiveButtonTitle: String?, otherButtonTitles firstButtonTitle: String, _ moreButtonTitles: String...) {

        self.init(title:title, cancelButtonTitle:cancelButtonTitle, destructiveButtonTitle:destructiveButtonTitle)
        self.addButtonWithTitle(firstButtonTitle)

        for buttonTitle in moreButtonTitles {
            self.addButtonWithTitle(buttonTitle)
        }
    }

    public convenience init(title: String?, cancelButtonTitle: String?, destructiveButtonTitle: String?) {
        
        let delegate_ = ActionSheetDelegate()
        self.init(title:title, delegate:delegate_, cancelButtonTitle:cancelButtonTitle, destructiveButtonTitle:destructiveButtonTitle)
        self.__delegate = delegate_
    }
    
    public func clicked(action:((buttonAtIndex:Int) -> ())?) -> UIActionSheet {
        self.__delegate?.clicked = action
        return self;
    }
    
    public func cancel(action:(() -> ())?) -> UIActionSheet {
        self.__delegate?.cancel = action
        return self;
    }
    
    public func willPresent(action:(() -> ())?) -> UIActionSheet {
        self.__delegate?.willPresent = action
        return self;
    }
    
    public func didPresent(action:(() -> ())?) -> UIActionSheet {
        self.__delegate?.didPresent = action
        return self;
    }
    
    public func willDismiss(action:((buttonAtIndex:Int) -> ())?) -> UIActionSheet {
        self.__delegate?.willDismiss = action
        return self;
    }
    
    public func didDismiss(action:((buttonAtIndex:Int) -> ())?) -> UIActionSheet {
        self.__delegate?.didDismiss = action
        return self;
    }
}

internal class ActionSheetDelegate :NSObject, UIActionSheetDelegate {
    
    typealias Action = () -> ()
    typealias IndexAction = (Int) -> ()
    
    var clicked: IndexAction?
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        self.clicked?(buttonIndex)
    }
    
    var cancel: Action?
    
    func actionSheetCancel(actionSheet: UIActionSheet) {
        self.cancel?()
    }
    
    var willPresent: Action?
    
    func willPresentActionSheet(actionSheet: UIActionSheet) {
        self.willPresent?()
    }
    
    var didPresent: Action?
    
    func didPresentActionSheet(actionSheet: UIActionSheet) {
        self.didPresent?()
    }
    
    var willDismiss: IndexAction?
    
    func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        self.willDismiss?(buttonIndex)
    }
    
    var didDismiss: IndexAction?
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        self.didDismiss?(buttonIndex)
    }
}

private var ActionSheetDelegateKey: UInt8 = 0

internal extension UIActionSheet {
    
    var __delegate: ActionSheetDelegate? {
        get {
            return objc_getAssociatedObject(self, &ActionSheetDelegateKey) as? ActionSheetDelegate
        }
        set {
            objc_setAssociatedObject(self, &ActionSheetDelegateKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
        }
    }
}
