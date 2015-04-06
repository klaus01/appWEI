//
//  ImageCollectionViewCell.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var urlImage: UrlImageView!
    
    var imageUrl: String? {
        get {
            return urlImage.imageUrl
        }
        set {
            urlImage.imageUrl = newValue
        }
    }
    
}
