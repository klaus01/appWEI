//
//  InviteFriendViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class InviteFriendViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    
    @IBAction func viewTapAction(sender: AnyObject) {
        phoneNumberTextField.resignFirstResponder()
    }
    
    @IBAction func inviteClick(sender: AnyObject) {
        if (getPhoneNumberAreaType(phoneNumberTextField.text) == .Error) {
            UIAlertView.showMessage("请输入有效的手机号")
            return
        }
        
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.enabled = false
        inviteButton.enabled = false
        
        ServerHelper.appUserAddFriend(phoneNumberTextField.text!, completionHandler: { [weak self] (ret, error) -> Void in
            if let obj = self {
            }
            else {
                return
            }
            self!.phoneNumberTextField.enabled = true
            self!.inviteButton.enabled = true
            
            if let error = error {
                println(error)
                return
            }
            
            if ret!.success {
                UIAlertView.showMessage(ret!.data!.message)
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteButton.layer.cornerRadius = 4;
        contactsButton.layer.cornerRadius = 4;
    }
    
}
