//
//  HomeViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/26.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.backgroundColor = THEME_BAR_COLOR
        
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.borderWidth = 4
        
        nicknameLabel.backgroundColor = THEME_BAR_COLOR
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width * 0.5
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        avatarImageView.imageWebUrl = UserInfo.shared.iconUrl
        nicknameLabel.text = UserInfo.shared.nickname
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is UserInfoViewController {
            (segue.destinationViewController as! UserInfoViewController).mode = .updateUser
        }
    }
}
