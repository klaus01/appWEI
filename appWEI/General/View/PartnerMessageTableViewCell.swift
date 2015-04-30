//
//  PartnerMessageTableViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/30.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class PartnerMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var message: HistoryMessageModel! {
        didSet {
            displayMessageImage(message, self.imgView, 10)
            dateLabel.text = message.message.createTime.stringWithFormat()
            if let activity = message.activity {
                contentLabel.text = activity.content
            }
            else if let gift = message.gift {
                contentLabel.text = "添加的活动中奖了"
            }
            else if let word = message.word {
                contentLabel.text = word.description
            }
            else {
                contentLabel.text = ""
            }
        }
    }
    
}
