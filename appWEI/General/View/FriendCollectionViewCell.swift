//
//  FriendCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    var iconImage: UIImage? {
        get {
            return iconImageView.image
        }
        set {
            iconImageView.image = newValue
        }
    }
    
    var nickname: String? {
        get {
            return nicknameLabel.text
        }
        set {
            nicknameLabel.text = newValue
        }
    }
    
    var messageCount: Int? {
        get {
            return messageCountLabel.text == nil ? 0 : messageCountLabel.text!.toInt()!
        }
        set {
            messageCountLabel.text = newValue == nil ? nil : "\(newValue)"
        }
    }
}
