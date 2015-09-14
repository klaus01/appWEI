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
        
        nicknameLabel.text = "我";
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width * 0.5
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is UserInfoViewController {
            (segue.destinationViewController as! UserInfoViewController).mode = .updateUser
        }
    }
}
