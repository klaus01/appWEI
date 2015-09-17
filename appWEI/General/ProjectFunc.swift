//
//  ProjectFunc.swift
//  appWEI
//
//  Created by kelei on 15/4/18.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import RSBarcodes

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
                        // 404 没有error，而且文件还被保存了
                        if response?.statusCode == 404 {
                            println(response)
                            NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
                            return
                        }
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

extension UIButton {
    
    private struct Static {
        static var AudioPlayerAssociationKey: UInt8 = 0
    }
    private var audioPlayer: AVAudioPlayer? {
        get {
            if let obj = objc_getAssociatedObject(self, &Static.AudioPlayerAssociationKey) as? AVAudioPlayer {
                return obj
            }
            return nil
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &Static.AudioPlayerAssociationKey, value, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
        }
    }
    private func playAmrFile(amrFilePath: String) {
        let wavFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("amrtowav.wav")
        if VoiceConverter.amrToWav(amrFilePath, wavSavePath: wavFilePath) > 0 {
            let session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
            session.setActive(true, error: nil)
            
            let player = AVAudioPlayer(contentsOfURL: NSURL(string: wavFilePath), error: nil)
            player.prepareToPlay()
            player.play()
            audioPlayer = player
        }
    }
    
    /**
    播放 字 的音频
    
    :param: url 音频文件URL
    */
    func playWordSoundUrl(url: String) {
        let fileName = url.lastPathComponent
        let filePath = getCachesDirectory() + "/" + fileName
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            self.playAmrFile(filePath)
        }
        else {
            download(Method.GET, url, { (temporaryURL, res) -> (NSURL) in
                return NSURL(string: "file://" + filePath)!
            }).response { [weak self] (request, response, dd, error) in
                // 404 没有error，而且文件还被保存了
                if response?.statusCode == 404 {
                    println(response)
                    NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
                    return
                }
                // errorCode 516: 下载后保存的目标文件已经存在(同一文件下载多次时出现)
                if error != nil && error!.code != 516 {
                    println(error)
                    return
                }
                if let weakSelf = self {
                    self!.playAmrFile(filePath)
                }
            }
        }
    }
    
    func stopPlayWordSound() {
        audioPlayer?.stop()
    }
}

extension UICollectionView {
    
    /**
    统一设置用户列表样式，每行3个，CellSize(100, 135)
    */
    func setUserListStyle() {
        setCellSize(CGSizeMake(100.0, 135.0), rowCount: 3)
    }
    
    /**
    根据CellSize和RowCount来设置Cell上下左右间距，使得上下左右间距相等
    
    :param: cellSize Cell宽高
    :param: rowCount 每行有多少个Cell
    */
    func setCellSize(cellSize: CGSize, rowCount: Int) {
        let ROW_COUNT = CGFloat(rowCount)
        let CELL_WIDTH = cellSize.width
        let CELL_HEIGHT = cellSize.height
        
        ce_LayoutSizeForItemAtIndexPath { (collectionView, collectionViewLayout, indexPath) -> CGSize in
            let size = CGSizeMake(CELL_WIDTH, CELL_HEIGHT)
            return size
        }
        ce_LayoutMinimumLineSpacingForSectionAtIndex { (collectionView, collectionViewLayout, section) -> CGFloat in
            return floor((collectionView.bounds.size.width - (ROW_COUNT * CELL_WIDTH)) / (ROW_COUNT + 1))
        }
        ce_LayoutInsetForSectionAtIndex { (collectionView, collectionViewLayout, section) -> UIEdgeInsets in
            let i = floor((collectionView.bounds.size.width - (ROW_COUNT * CELL_WIDTH)) / (ROW_COUNT + 1))
            return UIEdgeInsets(top: i, left: i, bottom: i, right: i)
        }
    }

}

/**
显示消息对应的图片

:param: message          消息对象
:param: imageView        显示到的UIImageView
:param: QRCodeImageScale 二维码图片放大位数（1不变）
*/
func displayMessageImage(message: HistoryMessageModel, imageView: UIImageView, QRCodeImageScale: CGFloat) {
    switch message.message.type {
    case .AddFriend:
        imageView.imageWebUrl = nil
        imageView.image = UIImage(named: "imagePlaceholder")
    case .Gift:
        imageView.imageWebUrl = nil
        let image = RSUnifiedCodeGenerator.shared.generateCode(SERVER_HOST_INTERFACE + "/activity/award?" + message.gift!.awardQRCodeInfo, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)
        if let i = image {
            imageView.image = RSAbstractCodeGenerator.resizeImage(i, scale: QRCodeImageScale)
        }
        else {
            imageView.image = nil
        }
    case .Activity:
        imageView.image = nil
        imageView.imageWebUrl = message.activity!.pictureUrl
    default:
        imageView.image = nil
        imageView.imageWebUrl = message.word!.pictureUrl
    }
}
