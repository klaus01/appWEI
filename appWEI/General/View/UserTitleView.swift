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
        let height = frame.size.height - 8 * 2
        label.sizeToFit()
        contentWidthConstraint.constant = height + 8 + label.frame.size.width
        imageView.layer.cornerRadius = height * 0.5
    }
    
}
