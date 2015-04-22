//
//  MessagesViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes

private func setUnreadMessageToImage(message: UnreadMessageModel, imageView: UIImageView, QRCodeImageScale: CGFloat) {
    switch message.message.type {
    case .AddFriend:
        imageView.imageWebUrl = nil
        imageView.image = UIImage(named: "imagePlaceholder")
    case .Gift:
        imageView.imageWebUrl = nil
        let image = RSUnifiedCodeGenerator.shared.generateCode(message.gift!.awardQRCodeInfo, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)
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

class MessagesViewController: UIViewController {

    @IBOutlet weak var wordImageView: UIImageView!
    @IBOutlet weak var wordSendTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    func setupCollectionView() {
        
        let ROW_COUNT = 6.0
        let CELL_WIDTH = 50.0
        let CELL_HEIGHT = 50.0
        
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
        .ce_NumberOfItemsInSection { (collectionView, section) -> Int in
            return UserInfo.shared.unreadMessages.count
//            return 10
        }
        .ce_CellForItemAtIndexPath { (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
            
            let message = UserInfo.shared.unreadMessages[indexPath.item]
            setUnreadMessageToImage(message, cell.urlImageView, 2.0)
//            cell.backgroundColor = UIColor.redColor()
//            cell.urlImageView.image = UIImage(named: "imagePlaceholder")
            return cell
        }
        .ce_DidSelectItemAtIndexPath { (collectionView, indexPath) -> Void in
            
        }
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
    
    func showMessage() {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
