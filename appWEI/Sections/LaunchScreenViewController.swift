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
            let stryBoard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = stryBoard.instantiateViewControllerWithIdentifier(identifier) as UIViewController
            window.rootViewController = rootViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "LaunchScreen", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? UIView {
            self.view = view
        }
        
        // 根据用户状态决定首界面
        ServerHelper.appUserIsLogged { (isLogged, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if let isLogged = isLogged {
                UserInfo.shared.isLogged = isLogged
                if isLogged {
                    // 已注册且已登录，根据用户注册状态决定
                    ServerHelper.appUserGet(UserInfo.shared.id, completionHandler: { (ret, error) -> Void in
                        if let error = error {
                            println(error)
                            return
                        }
                        if let ret = ret {
                            if let data = ret.data {
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
                    })
                }
                else {
                    // 未登录进入注册或登录界面
                    self.setRootViewControllerWithIdentifier("reg")
                }
            }
        }
        
    }

}
