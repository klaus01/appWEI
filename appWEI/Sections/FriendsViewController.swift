//
//  FriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    
    private var friends: [FriendModel]!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - IB
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func searchValueChanged(sender: AnyObject) {
        if let textField = sender as? UITextField {
            searchFriends(textField.text)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        setupRefreshControl();
        setupCollectionView();
        
        ce_addObserverForName(kNotification_UpdatingFriends) { [weak self] (notification) -> Void in
            self!.refreshControl.beginRefreshing()
        }
        ce_addObserverForName(kNotification_UpdateFriendsComplete) { [weak self] (notification) -> Void in
            self!.refreshControl.endRefreshing()
            self!.searchFriends(self!.textField.text)
        }
        
        friends = UserInfo.shared.whitelistFriends
    }
    
    deinit {
        ce_removeObserver()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserInfo.shared.isUpdatingFriends {
            refreshControl.beginRefreshing()
        }
    }
    
    private func setupCollectionView() {
        let cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        
        collectionView
            .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
                return self!.friends.count
            }
            .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
                let friend = self!.friends[indexPath.item]
                
                cell.iconImageUrl = friend.iconUrl
                cell.nickname = friend.nickname
                cell.deleteAction = nil
                if let count = friend.unreadCount {
                    cell.hintText = count > 0 ? "\(count)" : nil
                }
                else {
                    cell.hintText = nil
                }
                
                return cell;
            }
            .ce_DidSelectItemAtIndexPath { [weak self] (collectionView, indexPath) -> Void in
                let friend = self!.friends[indexPath.item]
                if friend.unreadCount != nil && friend.unreadCount! > 0 {
                    self!.performSegueWithIdentifier("showMessage", sender: nil)
                }
                else {
                    UIAlertView.showMessage("没有收到“\(friend.nickname!)”的消息")
                }
            }
            .setUserListStyle()
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.pulled { () -> () in
            UserInfo.shared.updateFriends()
        }
        collectionView.addSubview(refreshControl)
    }
    
    private func searchFriends(text: String?) {
        if text != nil && (text!.length > 0) {
            friends = UserInfo.shared.whitelistFriends.filter{ friend -> Bool in
                var nameSucc = false
                if let name = friend.nickname {
                    if let obj = name.matches(text!) {
                        nameSucc = obj.count > 0
                    }
                }
                var countSucc = false
                if let count = friend.unreadCount {
                    if let obj = "\(count)".matches(text!) {
                        countSucc = obj.count > 0
                    }
                }
                return nameSucc || countSucc
            }
        }
        else {
            friends = UserInfo.shared.whitelistFriends
        }
        collectionView.reloadData()
    }
}