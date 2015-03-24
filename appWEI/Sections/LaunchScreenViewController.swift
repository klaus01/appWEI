//
//  LaunchScreenViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/23.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    private func setRootViewControllerWithIdentifier(identifier: String) {
        let appDelegate = AppDelegate.shared()
        if let window = appDelegate?.window {
            let rootViewController = self.storyboard!.instantiateViewControllerWithIdentifier("mainNav") as UINavigationController
            window.rootViewController = rootViewController
            rootViewController.viewControllers = [self.storyboard!.instantiateViewControllerWithIdentifier(identifier) as UIViewController]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "LaunchScreen", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? UIView {
            self.view = view
        }
        
        if UserInfo.shared.id <= 0 {
            // 首次使用应用，还没注册过
            self.setRootViewControllerWithIdentifier("reg")
            return
        }
    
        // 注册过，根据用户状态决定首界面
        ServerHelper.appUserIsLogged { (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            UserInfo.shared.isLogged = ret!.success
            UserInfo.shared.save()
            if UserInfo.shared.isLogged {
                // 已注册且已登录，根据用户注册状态决定
                ServerHelper.appUserGet(UserInfo.shared.id) { (ret, error) -> Void in
                    if let error = error {
                        println(error)
                        return
                    }
                    if let data = ret!.data {
                        switch data.registrationStatus {
                        case 1:
                            // 手机号已验证
                            self.setRootViewControllerWithIdentifier("user")
                        case 2:
                            // 已完善了用户资料
                            self.setRootViewControllerWithIdentifier("show")
                        case 3:
                            // 已进入过主页
                            self.setRootViewControllerWithIdentifier("home")
                        default:
                            // 手机号已注册，但未验证手机号
                            self.setRootViewControllerWithIdentifier("reg")
                        }
                    }
                }
            }
            else {
                // 未登录进入注册或登录界面
                self.setRootViewControllerWithIdentifier("reg")
            }
        }
        
    }

}
