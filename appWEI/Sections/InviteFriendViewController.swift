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
    
    @IBAction func phoneNumberEditingChanged(sender: UITextField) {
        inviteButton.enabled = getPhoneNumberAreaType(sender.text) != .error
    }
    
    @IBAction func inviteClient(sender: AnyObject) {
        phoneNumberTextField.enabled = false
        inviteButton.enabled = false
        
        ServerHelper.appUserAddFriend(phoneNumberTextField.text!, completionHandler: { (ret, error) -> Void in
            self.phoneNumberTextField.enabled = true
            self.inviteButton.enabled = true
            
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
        inviteButton.enabled = false
    }

}
