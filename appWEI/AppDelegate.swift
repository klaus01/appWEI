//
//  AppDelegate.swift
//  appWEI
//
//  Created by kelei on 15/3/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func clearNotifications(application: UIApplication) {
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 分享相关设置 http://dashboard.mob.com/ShareSDK#/quickstarts/ios 第三步
        
        ShareSDK.registerApp("71e5245184cf")
        //添加微信应用 注册网址 http://open.weixin.qq.com
        ShareSDK.connectWeChatWithAppId("wx4868b35061f87885", wechatCls: WXApi.self)
        //微信登陆的时候需要初始化
        ShareSDK.connectWeChatWithAppId("wx4868b35061f87885", appSecret:"64020361b8ec4c99936c0e3999a9f249", wechatCls:WXApi.self)
        //添加Facebook应用  注册网址 https://developers.facebook.com
        ShareSDK.connectFacebookWithAppKey("107704292745179", appSecret:"38053202e1a5fe26c80c753071f0b573")
        //添加Instagram应用，此应用需要引用InstagramConnection.framework库 http://instagram.com/developer/clients/register/上注册应用，并将相关信息填写以下字段
        ShareSDK.connectInstagramWithClientId("ff68e3216b4f4f989121aa1c2962d058", clientSecret: "1b2e82f110264869b3505c3fe34e31a1", redirectUri: "http://sharesdk.cn")
//        // TODO 自定义UI分享
//        [ShareSDK shareContent:publishContent
//            type:ShareTypeSinaWeibo
//            authOptions:nil
//            shareOptions:nil
//            statusBarTips:YES
//            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//            if (state == SSPublishContentStateSuccess)
//            {
//            NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
//            }
//            else if (state == SSPublishContentStateFail)
//            {
//            NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
//            }
//            
//            }];
        
        // 注册远程通知UIApplicationLaunchOptionsRemoteNotificationKey
        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
            let settings = UIUserNotificationSettings(forTypes: .Alert | .Sound | .Badge, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        else {
            application.registerForRemoteNotificationTypes(.Alert | .Sound | .Badge)
        }
        
        // 处理应用通知数量
        clearNotifications(application)
        
        // 自定义BackButton样式，移除按钮文字
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -100), forBarMetrics: .Default)
        // 自定义NavigationBar样式
        UINavigationBar.appearance().barStyle = .Black;
        UINavigationBar.appearance().tintColor = THEME_BAR_TEXT_COLOR;
        UINavigationBar.appearance().barTintColor = THEME_BAR_COLOR;
//        UINavigationBar.appearance().titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:20]};
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        clearNotifications(application)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK:- Remote Notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description
            .replace("<", withString: "")
            .replace(">", withString: "")
            .replace(" ", withString: "")
        if UserInfo.shared.deviceToken != token {
            UserInfo.shared.deviceToken = token
            UserInfo.shared.save()
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("获取token失败：\(error)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        UserInfo.shared.updateUnreadMessages()
        UserInfo.shared.updateFriends()
    }
}

