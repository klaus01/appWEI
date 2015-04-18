//
//  FriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - public
    
    func updateFriendsComplete() {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - IB
    
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.pulled { () -> () in
            UserInfo.shared.updateFriends()
        }
        collectionView.addSubview(refreshControl)
        
        let cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
            .ce_NumberOfItemsInSection { (collectionView, section) -> Int in
                return UserInfo.shared.friends.count
            }
            .ce_CellForItemAtIndexPath { (collectionView, indexPath) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
                let friend = UserInfo.shared.friends[indexPath.row]
                if let appUser = friend.appUser {
                    cell.iconImageUrl = appUser.iconUrl
                    cell.nickname = appUser.nickname
                }
                else if let partnerUser = friend.partnerUser {
                    cell.iconImageUrl = partnerUser.iconUrl
                    cell.nickname = partnerUser.name
                }
                else {
                    cell.iconImageUrl = nil
                    cell.nickname = nil
                }
                if let count = friend.unreadCount {
                    cell.hintText = "\(count)"
                }
                else {
                    cell.hintText = nil
                }
                cell.deleteAction = nil
                return cell;
            }
        setUserListStyleWithCollectionView(collectionView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendsComplete", name: kNotification_UpdateFriendsComplete, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserInfo.shared.isUpdatingFriends {
            refreshControl.beginRefreshing()
        }
    }
    
}