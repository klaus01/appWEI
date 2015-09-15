//
//  RegisterViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    private var countdown = 0
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var regOrLoginButton: UIButton!
    
    @IBAction func phoneNumberEditingChanged(sender: UITextField) {
//        sendButton.hidden = getPhoneNumberAreaType(sender.text) == .Error
    }
    @IBAction func verificationCodeEditingChanged(sender: UITextField) {
//        regOrLoginButton.hidden = sender.text.length != VERIFICATIONCODE_LENGTH
    }
    @IBAction func sendClick(sender: UIButton) {
        let phoneNumber = phoneNumberTextField.text
        if (getPhoneNumberAreaType(phoneNumber) == .Error) {
            UIAlertView.showMessage("请输入有效的手机号")
            return
        }
        
        UserInfo.shared.phoneNumber = phoneNumber
        UserInfo.shared.save()
        
        sendButton.setTitle(sendButton.titleForState(.Normal), forState: .Disabled)
        sendButton.enabled = false
        
        ServerHelper.appUserRegisterAndSendCheck(phoneNumber, device: UIDevice.currentDevice().model, deviceOS: UIDevice.currentDevice().systemVersion) { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                self!.sendButton.enabled = true
                return
            }
            if ret!.success {
                UserInfo.shared.id = ret!.data!.appUserID
                UserInfo.shared.nickname = ret!.data!.nickname
                UserInfo.shared.iconUrl = ret!.data!.iconUrl
                UserInfo.shared.save()
//                self!.verificationCodeTextField.hidden = false
                self!.verificationCodeTextField.becomeFirstResponder()
                self!.countdown = VERIFICATIONCODE_INTERVAL + 1
                let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self!, selector: "onTimer:", userInfo: nil, repeats: true)
                timer.fire()
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }
    @IBAction func regOrLoginClick(sender: UIButton) {
        let phoneNumber = phoneNumberTextField.text
        if (getPhoneNumberAreaType(phoneNumber) == .Error) {
            UIAlertView.showMessage("请输入有效的手机号")
            return
        }
        if (verificationCodeTextField.text.length != VERIFICATIONCODE_LENGTH) {
            UIAlertView.showMessage("请输入\(VERIFICATIONCODE_LENGTH)位验证码")
            return
        }
        
        phoneNumberTextField.resignFirstResponder()
        verificationCodeTextField.resignFirstResponder()
        regOrLoginButton.enabled = false
        ServerHelper.smsCheckVerificationCode(UserInfo.shared.phoneNumber!, verificationCode: verificationCodeTextField.text) { [weak self] (ret, error) -> Void in
            self!.regOrLoginButton.enabled = true
            if let error = error {
                println(error)
                return
            }
            if ret!.success {
                UserInfo.shared.isLogged = true
                UserInfo.shared.save()
                UserInfo.shared.startHeartbeat()
                UserInfo.shared.updateFriends()
                UserInfo.shared.updateUnreadMessages()
                
                // 已注册且已登录，根据用户注册状态决定
                ServerHelper.appUserGet(UserInfo.shared.id) { [weak self] (ret, error) -> Void in
                    if let error = error {
                        println(error)
                        return
                    }
                    if let data = ret!.data {
                        switch data.registrationStatus {
                        case 1:
                            // 手机号已验证
                            self!.performSegueWithIdentifier("regToUser", sender: nil)
                        case 2:
                            // 已完善了用户资料
                            self!.performSegueWithIdentifier("regToShow", sender: nil)
                        default:
                            self!.performSegueWithIdentifier("regToHome", sender: nil)
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
            sendButton.enabled = true
        }
        else {
            sendButton.setTitle("\(countdown)", forState: UIControlState.Disabled)
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
        view.backgroundColor = THEME_BAR_COLOR
        phoneNumberTextField.textColor = THEME_BAR_COLOR
        verificationCodeTextField.textColor = THEME_BAR_COLOR
        sendButton.layer.cornerRadius = 5
        regOrLoginButton.setTitleColor(THEME_BAR_COLOR, forState: UIControlState.Normal)
//        regOrLoginButton.clipsToBounds = true
        
//        verificationCodeTextField.hidden = true
//        sendButton.hidden = true
//        regOrLoginButton.hidden = true
        
        phoneNumberTextField.ce_ShouldChangeCharactersInRange { [weak self] (textField, range, string) -> Bool in
            if string == "\n" && !self!.sendButton.hidden {
                textField.resignFirstResponder()
                self!.sendClick(self!.sendButton)
                return false
            }
            return true
        }
        
        verificationCodeTextField.ce_ShouldChangeCharactersInRange { [weak self] (textField, range, string) -> Bool in
            if string == "\n" && !self!.regOrLoginButton.hidden {
                textField.resignFirstResponder()
                self!.regOrLoginClick(self!.regOrLoginButton)
                return false
            }
            return true
        }
        
        if let phoneNumber = UserInfo.shared.phoneNumber {
            phoneNumberTextField.text = phoneNumber
            phoneNumberEditingChanged(phoneNumberTextField)
        }
        
        ce_addObserverForName(UIKeyboardWillShowNotification, handle: { [weak self] (notification) -> Void in
            if let info = notification.userInfo {
                if let frameValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    var kbRect = frameValue.CGRectValue()
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        var frame = self!.view.frame
                        frame.origin.y = kbRect.origin.y - frame.size.height
                        self!.view.frame = frame
                    })
                }
            }
        })
        ce_addObserverForName(UIKeyboardWillHideNotification, handle: { [weak self] (notification) -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frame = self!.view.frame
                frame.origin.y = 64
                self!.view.frame = frame
            })
        })
    }
    
    deinit {
        ce_removeObserver()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is UserInfoViewController {
            (segue.destinationViewController as! UserInfoViewController).navigationItem.hidesBackButton = true
            (segue.destinationViewController as! UserInfoViewController).title = "我"
        }
    }
}
