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
                            // errorCode 516: 下载后保存的目标文件已经存在(同一文件下载多次时出现)
                            if error != nil && error!.code != 516 {
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
    
    // 8.0及以上才能使用Kingfisher
//    private var imageTask: RetrieveImageTask?
//
//    var imageUrl: String? {
//        didSet {
//            imageTask?.cancel()
//            if let url = imageUrl {
//                imageTask = self.kf_setImageWithURL(NSURL(string: url)!, placeholderImage: UIImage(named: "imagePlaceholder"))
//            }
//            else {
//                imageTask = nil
//            }
//        }
//    }
    
}
