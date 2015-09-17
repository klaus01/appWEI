//
//  FriendCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var iconImageUrl: String? {
        didSet {
            if let url = iconImageUrl {
                iconImageView.imageWebUrl = url
            }
            else {
                iconImageView.imageWebUrl = nil
                iconImageView.image = nil
            }
        }
    }
    
    var nickname: String? {
        didSet {
            nicknameLabel.text = nickname
        }
    }
    
    var hintText: String? {
        didSet {
            hintLabel.text = hintText
            hintLabel.hidden = hintText == nil
        }
    }

    var clicked: ((cell: FriendCollectionViewCell) -> Void)? {
        didSet {
            if let action = clicked {
                tapGestureRecognizer = UITapGestureRecognizer() { [unowned self] (gestureRecognizer) -> () in
                    action(cell: self)
                }
                self.addGestureRecognizer(tapGestureRecognizer!)
            }
            else if tapGestureRecognizer != nil {
                self.removeGestureRecognizer(tapGestureRecognizer!)
                tapGestureRecognizer = nil
            }
        }
    }
    
    var longPressAction: ((cell: FriendCollectionViewCell) -> Void)? {
        didSet {
            if let action = longPressAction {
                longPressGestureRecognizer = UILongPressGestureRecognizer() { [unowned self] (gestureRecognizer) -> () in
                    action(cell: self)
                }
                self.addGestureRecognizer(longPressGestureRecognizer!)
            }
            else if longPressGestureRecognizer != nil {
                self.removeGestureRecognizer(longPressGestureRecognizer!)
                longPressGestureRecognizer = nil
            }
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hintLabel.layer.cornerRadius = hintLabel.bounds.size.width * 0.5
        iconImageView.layer.cornerRadius = iconImageView.bounds.size.width * 0.5
    }
    
}
