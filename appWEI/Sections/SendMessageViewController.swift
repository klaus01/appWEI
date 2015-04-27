//
//  SendMessageViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController {
    
    private let pageCount = 30
    private var allLoaded = false
    private var loadedCount: Int = 0
    private var lastUseWords: [WordModel] = [WordModel]()
    private var systemWords: [WordModel] = [WordModel]()
    private var userWords: [WordModel] = [WordModel]()
    private var currentWords: [WordModel] {
        switch wordGroupSegmentedControl.selectedSegmentIndex {
        case 1: return systemWords
        case 2: return userWords
        default: return lastUseWords
        }
    }
    private var friends: [AppUserModel] = [AppUserModel]()
    private var selectedWordCellFrame: CGRect?
    private var selectedWord: WordModel? {
        didSet {
            sendButton.enabled = selectedWord != nil
        }
    }
    private var selectedWordImageViewFrame: CGRect! {
        didSet {
            selectedWordImageViewTopConstraint.constant = selectedWordImageViewFrame.origin.y - navigationController!.navigationBar.frame.size.height - 20
            selectedWordImageViewLeftConstraint.constant = selectedWordImageViewFrame.origin.x - 16
            selectedWordImageViewWidthConstraint.constant = selectedWordImageViewFrame.size.width
            selectedWordImageViewHeightConstraint.constant = selectedWordImageViewFrame.size.height
        }
    }
    
    @IBOutlet weak var selectedWordImageView: UIImageView!
    @IBOutlet weak var selectedWordImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedWordImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedWordImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedWordImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordGroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wordCollectionView: UICollectionView!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelectedWordImageView()
        setupWordGroupSegmentedControl()
        setupWordCollectionView()
        setupFriendsCollectionView()
        
        hideSelectedWord(false)
        wordGroupSegmentedControl.selectedSegmentIndex = UserInfo.shared.lastUseWordIDs.count > 0 ? 0 : 1
    }

    private func setupWordGroupSegmentedControl() {
        wordGroupSegmentedControl.selectedIndexChange() { [weak self] (Int) -> () in
            self!.wordCollectionView.reloadData()
        }
    }
    
    private func setupSelectedWordImageView() {
        let tapGestureRecognizer = UITapGestureRecognizer() { [weak self] (gestureRecognizer) -> () in
            self!.hideSelectedWord(true)
        }
        selectedWordImageView.userInteractionEnabled = true
        selectedWordImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupWordCollectionView() {
        let ROW_COUNT = 3.0
        let CELL_WIDTH = 100.0
        let CELL_HEIGHT = 100.0
        
        let cellNib1 = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        wordCollectionView.registerNib(cellNib1, forCellWithReuseIdentifier: "MYCELL")
        let cellNib2 = UINib(nibName: "LoadingCollectionViewCell", bundle: nil)
        wordCollectionView.registerNib(cellNib2, forCellWithReuseIdentifier: "LOADCELL")
        wordCollectionView
        .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
            return self!.currentWords.count + (self!.allLoaded ? 0 : 1)
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            if self!.allLoaded == false && indexPath.item >= self!.currentWords.count {
                return collectionView.dequeueReusableCellWithReuseIdentifier("LOADCELL", forIndexPath: indexPath) as! UICollectionViewCell
            }
            else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
                let word = self!.currentWords[indexPath.item]
                cell.imageView.imageWebUrl = word.pictureUrl
                return cell
            }
        }
        .ce_DidSelectItemAtIndexPath { [weak self] (collectionView, indexPath) -> Void in
            if self!.allLoaded == false || indexPath.item < self!.currentWords.count {
                var frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame;
                frame.origin.x += collectionView.frame.origin.x
                frame.origin.y += collectionView.frame.origin.y
                self!.showSelectedWord(self!.currentWords[indexPath.item], wordFrame: frame)
            }
        }
        .ce_WillDisplayCell { [weak self] (collectionView, cell, indexPath) -> Void in
            if self!.allLoaded == false && indexPath.item >= self!.currentWords.count {
                self!.loadMoreWords()
            }
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
    
    private func setupFriendsCollectionView() {
        let ROW_COUNT = 6.0
        let CELL_WIDTH = 30.0
        let CELL_HEIGHT = 30.0
        
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        friendsCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        friendsCollectionView
        .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
            return self!.friends.count
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
            let friend = self!.friends[indexPath.item]
            cell.imageView.imageWebUrl = friend.iconUrl
            return cell
        }
        .ce_DidSelectItemAtIndexPath { (collectionView, indexPath) -> Void in
            // TODO 删除这个接收好友
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
    
    private func loadMoreWords() {
        ServerHelper.wordFindByAppUser(offset: loadedCount, resultCount: pageCount) { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if ret!.success {
                if let weakSelf = self, let data = ret!.data {
                    if data.count < self!.pageCount {
                        self!.allLoaded = true
                    }
                    if data.count > 0 {
                        self!.loadedCount += data.count
                        for word in data {
                            if word.createUserID != nil && word.createUserID! > 0 {
                                self!.userWords += [word]
                            }
                            else {
                                self!.systemWords += [word]
                            }
                        }
                        self!.reloadLastUseWords()
                    }
                    self!.wordCollectionView.reloadData()
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }
    
    private func reloadLastUseWords() {
        lastUseWords.removeAll(keepCapacity: true)
        for id in UserInfo.shared.lastUseWordIDs {
            var words = systemWords.filter({ (word) -> Bool in
                return word.id == id
            })
            if words.count > 0 {
                lastUseWords += words
            }
            else {
                var words = userWords.filter({ (word) -> Bool in
                    return word.id == id
                })
                if words.count > 0 {
                    lastUseWords += words
                }
            }
        }
    }
    
    private func showSelectedWord(word: WordModel, wordFrame: CGRect) {
        selectedWord = word
        selectedWordCellFrame = wordFrame
        selectedWordImageView.imageWebUrl = word.pictureUrl
        selectedWordImageViewFrame = wordFrame
        self.selectedWordImageView.layoutIfNeeded()
        UIView.animateWithDuration(0.3) { () -> Void in
            self.selectedWordImageView.hidden = false
            var frame = CGRectZero
            frame.origin = self.wordGroupSegmentedControl.frame.origin
            frame.size.width = self.wordGroupSegmentedControl.frame.size.width
            frame.size.height = CGRectGetMaxY(self.wordCollectionView.frame) - self.wordGroupSegmentedControl.frame.origin.y
            self.selectedWordImageViewFrame = frame
            self.selectedWordImageView.layoutIfNeeded()
        }
    }
    
    private func hideSelectedWord(animate: Bool) {
        if animate {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.selectedWordImageViewFrame = self.selectedWordCellFrame
                self.selectedWordImageView.layoutIfNeeded()
            }) { (success) -> Void in
                self.selectedWord = nil
                self.selectedWordCellFrame = nil
                self.selectedWordImageView.imageWebUrl = nil
                self.selectedWordImageView.hidden = true
            }
        }
        else {
            self.selectedWord = nil
            self.selectedWordCellFrame = nil
            self.selectedWordImageView.imageWebUrl = nil
            self.selectedWordImageView.hidden = true
        }
    }
    
    @IBAction func closeClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
