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
    private var userTitleView: UserTitleView?
    
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
        playButton.clicked() { [weak self] (button) -> () in
            if let message = self!.currentDisplayMessage {
                if message.message.type == .Word {
                    if let url = message.word!.audioUrl {
                        button.playWordSoundUrl(url)
                    }
                }
            }
        }
        wordView.longPressAction { [weak self] () -> () in
            if let message = self!.currentDisplayMessage {
                if message.message.type == .Word {
                    ServerHelper.wordSend(message.word!.id, friendsUsers: [message.appUser!.appUserID], completionHandler: { [weak self] (ret, error) -> Void in
                        if let error = error {
                            println(error)
                            return
                        }
                        if let weakSelf = self {
                            if ret!.success {
                                UIAlertView.showMessage("原消息回复成功")
                            }
                            else {
                                UIAlertView.showMessage(ret!.errorMessage!)
                            }
                        }
                    })
                }
            }
        }
        forwardButton.clicked() { (button) -> () in
            // TODO 转发消息
        }
        
        reloadUnreadMessages()
        ce_addObserverForName(kNotification_UpdateUnreadMessagesComplete) { [weak self] (notification) -> Void in
            self!.reloadUnreadMessages()
        }
        
        self.navigationItem.titleView = nil;
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        playButton.stopPlayWordSound()
    }
    
    private func setupCollectionView() {
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
            self!.showUserInfoWithMessage(message)
            self!.showUnreadMessage(message)
            self!.collectionView.deleteItemsAtIndexPaths([indexPath])
        }
        .setCellSize(CGSizeMake(50, 50), rowCount: 6)
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
        
        ServerHelper.messageSetRead(message.message.id, completionHandler: { (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            UserInfo.shared.removeUnreadMessage(message.message.id)
            UserInfo.shared.updateFriends()
        })
    }
    
    private func showUserInfoWithMessage(message: HistoryMessageModel) {
        if (userTitleView == nil) {
            userTitleView = NSBundle.mainBundle().loadNibNamed("UserTitleView", owner: nil, options: nil).first as? UserTitleView
            navigationItem.titleView = userTitleView
            userTitleView!.backgroundColor = UIColor.clearColor()
            userTitleView!.frame = CGRectMake(0, 0, userTitleView!.superview!.bounds.size.width, userTitleView!.superview!.bounds.size.height)
        }
        if let view = userTitleView {
            view.imageView.imageWebUrl = message.iconUrl
            view.label.text = message.nickname
            view.autoContnetSize()
        }
    }
    
    deinit {
        ce_removeObserver()
    }
    
}
