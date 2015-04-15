//
//  FriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    
    private let ROW_COUNT = 3.0
    private let CELL_WIDTH = 100.0
    private let CELL_HEIGHT = 120.0
    
    private let refreshControl = UIRefreshControl()
    
    private func getCellSpacing(collectionView: UICollectionView) -> Double {
        return (Double(collectionView.bounds.size.width) - (ROW_COUNT * CELL_WIDTH)) / 4.0
    }
    
    // MARK: - public
    
    func updateFriendsComplete() {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - IB
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.None

        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.pulled { () -> () in
            UserInfo.shared.updateFriends()
        }
        collectionView.addSubview(refreshControl)
        
        let cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
            .ce_LayoutSizeForItemAtIndexPath { (collectionView, collectionViewLayout, indexPath) -> CGSize in
                return CGSize(width: self.CELL_WIDTH, height: self.CELL_HEIGHT)
            }
            .ce_LayoutMinimumLineSpacingForSectionAtIndex { (collectionView, collectionViewLayout, section) -> CGFloat in
                return CGFloat(self.getCellSpacing(collectionView))
            }
            .ce_LayoutInsetForSectionAtIndex { (collectionView, collectionViewLayout, section) -> UIEdgeInsets in
                    let i = CGFloat(self.getCellSpacing(collectionView))
                    return UIEdgeInsets(top: i, left: i, bottom: i, right: i)
            }
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
                cell.messageCount = friend.unreadCount
                return cell;
            }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendsComplete", name: kNotification_UpdateFriendsComplete, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserInfo.shared.isUpdatingFriends {
            refreshControl.beginRefreshing()
        }
    }
    
}