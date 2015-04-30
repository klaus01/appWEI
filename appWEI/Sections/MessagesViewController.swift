//
//  MessagesViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import AVFoundation

class WordView: UIView {
    
    private var isAnimation = false
    
    @IBOutlet weak var wordImageView: UIImageView!
    @IBOutlet weak var wordMaskView: UIView!
    @IBOutlet weak var wordButton: UIButton!
    
    private var _longPressAction: (() -> ())?
    
    var message: HistoryMessageModel! {
        didSet {
            displayMessageImage(message, wordImageView, 10)
            setupWordMaskView()
            setupWordButton()
        }
    }
    
    private func setupWordMaskView() {
        var frame = self.wordMaskView.superview!.bounds
        frame.origin.y = frame.size.height
        frame.size.height = 0
        self.wordMaskView.frame = frame
        self.wordMaskView.alpha = 0.3
    }
    
    private func setupWordButton() {
        wordButton.hidden = message.message.type != .Word
        wordButton.__on(UIControlEvents.TouchDown) { [weak self] (control) -> () in
            self!.setupWordMaskView()
            self!.isAnimation = true
            UIView.setAnimationsEnabled(true)
            UIView.animateWithDuration(2.0, animations: { [weak self] () -> Void in
                self!.wordMaskView.frame = self!.wordMaskView.superview!.bounds
                }, completion: { [weak self] (success) -> Void in
                    self!.isAnimation = false
                    if success {
                        UIView.animateWithDuration(0.3, animations: { [weak self] () -> Void in
                            self!.wordMaskView.alpha = 0
                            })
                        if let f = self!._longPressAction {
                            f()
                        }
                    }
                })
        }
        let touchUpAction = { [weak self] (control: UIControl) -> () in
            if self!.isAnimation {
                self!.setupWordMaskView()
                self!.wordMaskView.layer.removeAllAnimations()
            }
        }
        wordButton.__on(UIControlEvents.TouchUpInside, action: touchUpAction)
        wordButton.__on(UIControlEvents.TouchUpOutside, action: touchUpAction)
    }
    
    func longPressAction(action: () -> ()) {
        _longPressAction = action
    }
}

class MessagesViewController: UIViewController {

    private var unreadMessages: [HistoryMessageModel]!
    private var currentDisplayMessage: HistoryMessageModel?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var wordView: WordView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var wordSendTimeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        wordView.hidden = true
        wordSendTimeLabel.hidden = true
        playButton.hidden = true
        forwardButton.hidden = true
        playButton.clicked() { (button) -> () in
            // TODO 播放音频
        }
        wordView.longPressAction { () -> () in
            // TODO 原消息回复
        }
        forwardButton.clicked() { (button) -> () in
            // TODO 转发消息
        }
        
        reloadUnreadMessages()
        ce_addObserverForName(kNotification_UpdateUnreadMessagesComplete) { [weak self] (notification) -> Void in
            self!.reloadUnreadMessages()
        }
    }

    private func setupCollectionView() {
        
        let ROW_COUNT = 6.0
        let CELL_WIDTH = 50.0
        let CELL_HEIGHT = 50.0
        
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
        .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
            return self!.unreadMessages.count
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
            let message = self!.unreadMessages[indexPath.item]
            displayMessageImage(message, cell.imageView, 2.0)
            return cell
        }
        .ce_DidSelectItemAtIndexPath { [weak self] (collectionView, indexPath) -> Void in
            let message = self!.unreadMessages.removeAtIndex(indexPath.item)
            self!.showUnreadMessage(message)
//            self!.collectionView.deleteItemsAtIndexPaths([indexPath])
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
    
    private func reloadUnreadMessages() {
        unreadMessages = UserInfo.shared.unreadMessages
        collectionView.reloadData()
    }
    
    private func showUnreadMessage(message: HistoryMessageModel) {
        currentDisplayMessage = message;
        
        wordView.hidden = false
        wordView.message = message
        wordSendTimeLabel.hidden = false
        wordSendTimeLabel.text = message.message.createTime.stringWithFormat("HH:mm")
        playButton.hidden = message.message.type != .Word || message.word?.audioUrl == nil
        forwardButton.hidden = message.message.type != .Word
        
//        ServerHelper.messageSetRead(message.message.id, completionHandler: { (ret, error) -> Void in
//            if let error = error {
//                println(error)
//                return
//            }
//            UserInfo.shared.removeUnreadMessage(message.message.id)
//            UserInfo.shared.updateFriends()
//        })
    }
    
    deinit {
        ce_removeObserver()
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
