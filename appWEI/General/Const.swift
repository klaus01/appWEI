//
//  const.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import AdSupport

// 应用与设备唯一标识
let UUIDString = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString

// 服务端域名
#if DEBUG
let SERVER_HOST_RESOURCE_FILE   = "http://192.168.199.101:3001"
let SERVER_HOST_INTERFACE       = "http://192.168.199.101:3001"
#else
let SERVER_HOST_RESOURCE_FILE   = "http://weiapp.cf:3000"
let SERVER_HOST_INTERFACE       = "http://weiapp.cf:3001"
#endif

// 获取验证码的间隔时间(秒)
let VERIFICATIONCODE_INTERVAL   = 60
// 验证码长度
let VERIFICATIONCODE_LENGTH     = 6
// 多久上传一次经纬度坐标(秒)
let UPLOADLOCATION_INTERVAL     = 5 * 60.0