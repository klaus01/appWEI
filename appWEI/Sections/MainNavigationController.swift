//
//  MainNavigationController.swift
//  appWEI
//
//  Created by kelei on 15/5/13.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationBar.translucent = false
        navigationBar.barStyle = UIBarStyle.Black
        navigationBar.tintColor = THEME_BAR_TEXT_COLOR
        navigationBar.barTintColor = THEME_BAR_COLOR
        
        ce_addObserverForName(kNotification_NotLogged, handle: { [weak self] (notification) -> Void in
            if self!.topViewController is RegisterViewController {
                return
            }
            let registerViewController = self!.storyboard!.instantiateViewControllerWithIdentifier("reg") as! UIViewController
            self!.setViewControllers([registerViewController], animated: true)
        })
    }
    
    deinit {
        ce_removeObserver()
    }
}
