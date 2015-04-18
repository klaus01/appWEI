//
//  ImageCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var urlImage: UIImageView!
    
    var imageUrl: String? {
        didSet {
            if let url = imageUrl {
                urlImage.loadImageWithUrl(url)
            }
        }
    }
    
}
