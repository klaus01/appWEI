//
//  WordTableViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var number: String? {
        get {
            return noLabel.text
        }
        set {
            noLabel.text = number
        }
    }
    
    var pictureImageUrl: String? {
        didSet {
            if let url = pictureImageUrl {
                pictureImageView.imageWebUrl = url
            }
            else {
                pictureImageView.imageWebUrl = nil
                pictureImageView.image = nil
            }
        }
    }
    
    var rightText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = number
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
