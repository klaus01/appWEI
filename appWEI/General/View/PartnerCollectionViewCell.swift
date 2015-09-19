//
//  PartnerCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/9/19.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class PartnerCollectionViewCell: UICollectionViewCell {
    
    enum HintType {
        case None
        case NewMessage
        case Prize
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 3
        hintLabel.layer.cornerRadius = 10
        hintLabel.textColor = UIColor.whiteColor()
    }

    var hintType: HintType = .None {
        didSet {
            switch hintType {
            case .NewMessage:
                hintLabel.text = "新"
                hintLabel.backgroundColor = UIColor(red: 214.0/255.0, green: 29.0/255.0, blue: 29.0/255.0, alpha: 1)
                hintLabel.hidden = false
            case .Prize:
                hintLabel.text = "奖"
                hintLabel.backgroundColor = UIColor(red: 255.0/255.0, green: 168.0/255.0, blue: 0.0, alpha: 1)
                hintLabel.hidden = false
            default:
                hintLabel.hidden = true
            }
        }
    }
    
    var iconImageUrl: String? {
        didSet {
            imgView.image = nil
            if let url = iconImageUrl {
                imgView.imageWebUrl = url
            }
            else {
                imgView.imageWebUrl = nil
            }
        }
    }
    
    var nickname: String? {
        didSet {
            titleLabel.text = nickname
        }
    }
    
}
