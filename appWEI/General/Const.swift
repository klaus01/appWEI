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
let SERVER_HOST = "http://localhost:3001"
#else
let SERVER_HOST = "http://weiapp.cf:3001"
#endif

// 获取验证码的间隔时间(秒)
let VERIFICATIONCODE_INTERVAL = 60
// 验证码长度
let VERIFICATIONCODE_LENGTH = 6