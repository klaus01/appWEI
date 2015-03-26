//
//  RegisterViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    private var sendButtonDefaultTitle: String!
    private var countdown = 0
    private var timer: NSTimer!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var regOrLoginButton: UIButton!
    
    @IBAction func phoneNumberEditingChanged(sender: UITextField) {
        sendButton.hidden = getPhoneNumberAreaType(sender.text) == .error
    }
    @IBAction func verificationCodeEditingChanged(sender: UITextField) {
        regOrLoginButton.hidden = sender.text.length != VERIFICATIONCODE_LENGTH
    }
    @IBAction func sendClick(sender: UIButton) {
        let phoneNumber = phoneNumberTextField.text
        
        UserInfo.shared.phoneNumber = phoneNumber
        UserInfo.shared.save()
        
        sendButton.enabled = false
        
        ServerHelper.appUserRegisterAndSendCheck(phoneNumber, device: UIDevice.currentDevice().name, deviceOS: UIDevice.currentDevice().systemVersion) { (ret, error) -> Void in
            if let error = error {
                println(error)
                self.sendButton.enabled = true
                return
            }
            if ret!.success {
                UserInfo.shared.id = ret!.data!.appUserID
                UserInfo.shared.save()
                self.verificationCodeTextField.hidden = false
                self.verificationCodeTextField.becomeFirstResponder()
                self.countdown = VERIFICATIONCODE_INTERVAL
                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTimer:", userInfo: nil, repeats: true)
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }
    @IBAction func regOrLoginClick(sender: UIButton) {
        regOrLoginButton.enabled = false
        ServerHelper.smsCheckVerificationCode(UserInfo.shared.phoneNumber!, verificationCode: verificationCodeTextField.text) { (ret, error) -> Void in
            self.regOrLoginButton.enabled = true
            if let error = error {
                println(error)
                return
            }
            if ret!.success {
                UserInfo.shared.isLogged = true
                UserInfo.shared.save()
                
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
                            self.performSegueWithIdentifier("regToUser", sender: nil)
                        case 2:
                            // 已完善了用户资料
                            self.performSegueWithIdentifier("regToShow", sender: nil)
                        default:
                            self.performSegueWithIdentifier("regToHome", sender: nil)
                        }
                    }
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }

    func onTimer(timer: NSTimer) {
        countdown--
        if countdown <= 0 {
            timer.invalidate()
            sendButton.setTitle(sendButtonDefaultTitle, forState: UIControlState.Normal)
            sendButton.enabled = true
        }
        else {
            sendButton.setTitle("\(countdown)秒后可重新发送", forState: UIControlState.Normal)
        }
    }
    
    private func performSegue() {
        ServerHelper.appUserGet(UserInfo.shared.id) { (ret, error) -> Void in
            if let error = error {
                println(error)
                self.regOrLoginButton.enabled = true
                return
            }
            if ret!.success {
                if let data = ret!.data {
                    switch data.registrationStatus {
                    case 1:
                        // 手机号已验证
                        self.performSegueWithIdentifier("regToUser", sender: nil)
                    case 2:
                        // 已完善了用户资料
                        self.performSegueWithIdentifier("regToShow", sender: nil)
                    case 3:
                        // 已进入过主页
                        self.performSegueWithIdentifier("regToHome", sender: nil)
                    default:
                        UIAlertView.showMessage("用户注册状态错误\(data.registrationStatus)")
                    }
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButtonDefaultTitle = sendButton.titleForState(UIControlState.Normal)
        verificationCodeTextField.hidden = true
        sendButton.hidden = true
        regOrLoginButton.hidden = true
        
        if let phoneNumber = UserInfo.shared.phoneNumber {
            phoneNumberTextField.text = phoneNumber
            phoneNumberEditingChanged(phoneNumberTextField)
        }
    }

}
