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
    private var lastUseWords: [WordModel]!
    private var sytemWords: [WordModel]!
    private var userWords: [WordModel]!
    private var currentWords: [WordModel] {
        switch wordGroupSegmentedControl.selectedSegmentIndex {
        case 1: return sytemWords
        case 2: return userWords
        default: return lastUseWords
        }
    }
    private var friends: [AppUserModel] = [AppUserModel]()
    
    @IBOutlet weak var wordGroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wordCollectionView: UICollectionView!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWordGroupSegmentedControl()
        setupWordCollectionView()
        setupFriendsCollectionView()
    }

    private func setupWordGroupSegmentedControl() {
        wordGroupSegmentedControl.selectedIndexChange() { [weak self] (Int) -> () in
            self!.wordCollectionView.reloadData()
        }
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
        .ce_DidSelectItemAtIndexPath { (collectionView, indexPath) -> Void in
            // TODO 使用这个字
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
                        // TODO 将data中的数据分散到3个words中
                    }
                    self!.wordCollectionView.reloadData()
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }
    
    @IBAction func closeClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
