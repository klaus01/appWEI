//
//  UrlImageView.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class UrlImageView: UIImageView {

    private var imageTask: RetrieveImageTask?
    
    var imageUrl: String? {
        didSet {
            imageTask?.cancel()
            if let url = imageUrl {
                imageTask = self.kf_setImageWithURL(NSURL(string: url)!, placeholderImage: UIImage(named: "imagePlaceholder"))
            }
            else {
                imageTask = nil
            }
        }
    }
    
}
