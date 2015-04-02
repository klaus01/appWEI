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
    
    private var _iconImageUrl: String?
    var iconImageUrl: String? {
        get {
            return _iconImageUrl
        }
        set {
            if _iconImageUrl != newValue {
                _iconImageUrl = newValue
                if let _iconImageUrl = _iconImageUrl {
                    let fileName = (_iconImageUrl as NSString).lastPathComponent
                    let filePath = getCachesDirectory() + "/" + fileName
                    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                        iconImageView.image = UIImage(contentsOfFile: filePath)
                    }
                    else {
                        let hud = JHProgressHUD()
                        hud.backGroundColor = UIColor.whiteColor()
                        hud.loaderColor = UIColor.blackColor()
                        hud.showInView(iconImageView)
                        download(Method.GET, _iconImageUrl, { (temporaryURL, res) -> (NSURL) in
                            return NSURL(string: "file://" + filePath)!
                        }).response { (request, response, _, error) in
                            if let error = error {
                                println(error)
                                return
                            }
                            hud.hide()
                            self.iconImageView.image = UIImage(contentsOfFile: filePath)
                        }
                    }
                }
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
    
    var messageCount: Int? {
        get {
            return messageCountLabel.text == nil ? 0 : messageCountLabel.text!.toInt()!
        }
        set {
            messageCountLabel.text = newValue == nil ? nil : "\(newValue)"
        }
    }
}
