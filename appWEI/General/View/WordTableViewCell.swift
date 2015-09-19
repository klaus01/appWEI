//
//  WordTableViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    class var cellHeight: CGFloat { return 67 }
    
    var pictureImageUrl: String? {
        didSet {
            pictureImageView.image = nil
            if let url = pictureImageUrl {
                pictureImageView.imageWebUrl = url
            }
            else {
                pictureImageView.imageWebUrl = nil
            }
        }
    }
    
    var rightText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }
    
}
