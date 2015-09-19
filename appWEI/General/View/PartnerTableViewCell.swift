//
//  PartnerTableViewCell.swift
//  appWEI
//
//  Created by kelei on 15/9/19.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class PartnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        pictureImageView.layer.cornerRadius = 3
        descLabel.numberOfLines = 2
        button.setImage(UIImage(named: "checkbox_checked"), forState: UIControlState.Disabled)
    }
    
    class var cellHeight: CGFloat { return 117 }
    
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
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var desc: String? {
        didSet {
            descLabel.text = desc
        }
    }
    
    var subscribe: ((cell: PartnerTableViewCell) -> ())? {
        didSet {
            if let action = subscribe {
                button.clicked { [weak self] btn -> () in
                    if let action = self!.subscribe {
                        action(cell: self!)
                    }
                }
                button.enabled = true
            }
            else {
                button.enabled = false
            }
        }
    }
    
}
