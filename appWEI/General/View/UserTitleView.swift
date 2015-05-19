//
//  UserTitleView.swift
//  appWEI
//
//  Created by kelei on 15/5/19.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class UserTitleView: UIView {
    
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func autoContnetSize() {
        label.sizeToFit()
        contentWidthConstraint.constant = (frame.size.height - 8 * 2) + 8 + label.frame.size.width
    }
    
}
