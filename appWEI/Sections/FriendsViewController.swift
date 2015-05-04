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
    
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        setupRefreshControl();
        setupCollectionView();
        
        self.ce_addObserverForName(kNotification_UpdateFriendsComplete) { [weak self] (notification) -> Void in
            self!.friends = UserInfo.shared.whitelistFriends
            self!.collectionView.reloadData()
            self!.refreshControl.endRefreshing()
        }
        
        friends = UserInfo.shared.whitelistFriends
    }
    
    deinit {
        self.ce_removeObserver()
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
        setUserListStyleWithCollectionView(collectionView)
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.pulled { () -> () in
            UserInfo.shared.updateFriends()
        }
        collectionView.addSubview(refreshControl)
    }
    
}