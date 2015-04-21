//
//  ProjectFunc.swift
//  appWEI
//
//  Created by kelei on 15/4/18.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    private struct Static {
        static var UrlAssociationKey: UInt8 = 0
        static var RequestAssociationKey: UInt8 = 0
    }
    private var downloadImageRequest: Request? {
        get {
            if let obj = objc_getAssociatedObject(self, &Static.RequestAssociationKey) as? Request {
                return obj
            }
            return nil
        }
        set {
            if let request = newValue {
                objc_setAssociatedObject(self, &Static.RequestAssociationKey, request, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
        }
    }
    var imageWebUrl: String? {
        get {
            if let obj = objc_getAssociatedObject(self, &Static.UrlAssociationKey) as? NSString {
                return String(obj)
            }
            return nil
        }
        set {
            if let oldResponse = self.downloadImageRequest {
                oldResponse.cancel()
            }
            
            if let url = newValue {
                let urlString = NSString(string: url)
                objc_setAssociatedObject(self, &Static.UrlAssociationKey, urlString, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
                let fileName = urlString.lastPathComponent
                let filePath = getCachesDirectory() + "/" + fileName
                if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                    self.image = UIImage(contentsOfFile: filePath)
                }
                else {
                    let request = download(Method.GET, url, { (temporaryURL, res) -> (NSURL) in
                        return NSURL(string: "file://" + filePath)!
                    })
                    request.response { (request, response, _, error) in
                        // errorCode 516: 下载后保存的目标文件已经存在(同一文件下载多次时出现)
                        if error != nil && error!.code != 516 {
                            println(error)
                            return
                        }
                        self.image = UIImage(contentsOfFile: filePath)
                    }
                    self.downloadImageRequest = request
                }
            }
            else {
                objc_removeAssociatedObjects(self)
            }
        }
    }
    
    /**
    加载网络图片（下载到本地保存，下次请求时从本地加载）
    
    :param: url 图片网址
    */
//    func loadImageWithUrl(url: String) {
//        let fileName = (url as NSString).lastPathComponent
//        let filePath = getCachesDirectory() + "/" + fileName
//        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
//            self.image = UIImage(contentsOfFile: filePath)
//        }
//        else {
//            let hud = JHProgressHUD()
//            hud.backGroundColor = UIColor.whiteColor()
//            hud.loaderColor = UIColor.blackColor()
//            hud.showInView(self)
//            download(Method.GET, url, { (temporaryURL, res) -> (NSURL) in
//                return NSURL(string: "file://" + filePath)!
//            }).response { (request, response, _, error) in
//                // errorCode 516: 下载后保存的目标文件已经存在(同一文件下载多次时出现)
//                if error != nil && error!.code != 516 {
//                    println(error)
//                    return
//                }
//                hud.hide()
//                self.image = UIImage(contentsOfFile: filePath)
//            }
//        }
//    }
    
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

/**
统一设置用户列表样式

:param: collectionView
*/
func setUserListStyleWithCollectionView(collectionView: UICollectionView) {
    
    let ROW_COUNT = 3.0
    let CELL_WIDTH = 100.0
    let CELL_HEIGHT = 120.0
    
    collectionView
        .ce_LayoutSizeForItemAtIndexPath { (collectionView, collectionViewLayout, indexPath) -> CGSize in
            return CGSize(width: CELL_WIDTH, height: CELL_HEIGHT)
        }
        .ce_LayoutMinimumLineSpacingForSectionAtIndex { (collectionView, collectionViewLayout, section) -> CGFloat in
            return CGFloat((Double(collectionView.bounds.size.width) - (ROW_COUNT * CELL_WIDTH)) / (ROW_COUNT + 1))
        }
        .ce_LayoutInsetForSectionAtIndex { (collectionView, collectionViewLayout, section) -> UIEdgeInsets in
            let i = CGFloat((Double(collectionView.bounds.size.width) - (ROW_COUNT * CELL_WIDTH)) / (ROW_COUNT + 1))
            return UIEdgeInsets(top: i, left: i, bottom: i, right: i)
    }
}
