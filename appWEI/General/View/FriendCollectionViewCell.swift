//
//  FriendCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UrlImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    var iconImageUrl: String? {
        get {
            return iconImageView.imageUrl
        }
        set {
            iconImageView.imageUrl = newValue
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
            return messageCountLabel.text == nil ? nil : messageCountLabel.text!.toInt()!
        }
        set {
            messageCountLabel.text = newValue == nil ? nil : "\(newValue)"
        }
    }
    
}
