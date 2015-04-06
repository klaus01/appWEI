//
//  UrlImageView.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class UrlImageView: UIImageView {

    private var _imageUrl: String?
    var imageUrl: String? {
        get {
            return _imageUrl
        }
        set {
            if _imageUrl != newValue {
                _imageUrl = newValue
                if let _imageUrl = _imageUrl {
                    let fileName = (_imageUrl as NSString).lastPathComponent
                    let filePath = getCachesDirectory() + "/" + fileName
                    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                        self.image = UIImage(contentsOfFile: filePath)
                    }
                    else {
                        let hud = JHProgressHUD()
                        hud.backGroundColor = UIColor.whiteColor()
                        hud.loaderColor = UIColor.blackColor()
                        hud.showInView(self)
                        download(Method.GET, _imageUrl, { (temporaryURL, res) -> (NSURL) in
                            return NSURL(string: "file://" + filePath)!
                        }).response { (request, response, _, error) in
                            if let error = error {
                                println(error)
                                return
                            }
                            hud.hide()
                            self.image = UIImage(contentsOfFile: filePath)
                        }
                    }
                }
            }
        }
    }
    
}
