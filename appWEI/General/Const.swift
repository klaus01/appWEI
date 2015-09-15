//
//  const.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

// 服务端域名
#if DEBUG
let SERVER_HOST_RESOURCE_FILE   = "http://192.168.1.3:3001"
let SERVER_HOST_INTERFACE       = "http://192.168.1.3:3001"
#else
let SERVER_HOST_RESOURCE_FILE   = "http://weiapp.cf"
let SERVER_HOST_INTERFACE       = "http://weiapp.cf:3001"
#endif

/// 获取验证码的间隔时间(秒)
let VERIFICATIONCODE_INTERVAL   = 60
/// 验证码长度
let VERIFICATIONCODE_LENGTH     = 6
/// 多久上传一次经纬度坐标(秒)
let UPLOADLOCATION_INTERVAL     = 5 * 60

/// 导航栏背景色
let THEME_BAR_COLOR = UIColor(red: 37/255.0, green: 161/255.0, blue: 157/255.0, alpha: 1)
/// 导航栏字体色
let THEME_BAR_TEXT_COLOR = UIColor.whiteColor()