//
//  StatisticsWordTableViewCell.swift
//  appWEI
//
//  Created by kelei on 15/9/19.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class StatisticsWordTableViewCell: UITableViewCell {
    
    private var progressConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
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
    
    var allCount: Int = 0 {
        didSet {
            refreshProgressViewWidth()
        }
    }
    
    var count: Int = 0 {
        didSet {
            countLabel.text = "\(count)"
            refreshProgressViewWidth()
        }
    }
    
    private func refreshProgressViewWidth() {
        var progress: CGFloat = 0
        if count > 0 && allCount > 0 {
            progress = CGFloat(count) / CGFloat(allCount);
        }
        if (progressConstraint != nil) {
            if progressConstraint!.multiplier == progress {
                return
            }
            progressBarView.removeConstraint(progressConstraint!)
        }
        let newConstraint = NSLayoutConstraint(item: progressView, attribute: .Width, relatedBy: .Equal, toItem: progressBarView, attribute: .Width, multiplier: progress, constant: 0)
        progressConstraint = newConstraint
        progressBarView.addConstraint(newConstraint)
        progressBarView.setNeedsLayout()
    }
}
