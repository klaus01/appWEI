//
//  FriendCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var iconImageUrl: String? {
        didSet {
            if let url = iconImageUrl {
                iconImageView.loadImageWithUrl(url)
            }
            else {
                iconImageView.image = nil
            }
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
    
    var hintText: String? {
        get {
            return hintLabel.text
        }
        set {
            hintLabel.text = newValue
        }
    }

    var deleteAction: ((cell: FriendCollectionViewCell) -> Void)? {
        didSet {
            deleteButton.hidden = true
            if let action = deleteAction {
                deleteButton.clicked() { [unowned self] (button) -> Void in
                    action(cell: self)
                }
                longPressGestureRecognizer = UILongPressGestureRecognizer() { [unowned self] (gestureRecognizer) -> () in
                    self.deleteButton.hidden = false
                }
                self.addGestureRecognizer(longPressGestureRecognizer!)
            }
            else {
                deleteButton.clicked(action: nil)
                if longPressGestureRecognizer != nil {
                    self.removeGestureRecognizer(longPressGestureRecognizer!)
                    longPressGestureRecognizer = nil
                }
            }
        }
    }
    
}
