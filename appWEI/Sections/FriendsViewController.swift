//
//  FriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController/*, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PZPullToRefreshDelegate*/ {
    
    private let ROW_COUNT = 3.0
    private let CELL_WIDTH = 100.0
    private let CELL_HEIGHT = 120.0
    
    private var refreshHeaderView: PZPullToRefreshView?

    private func getCellSpacing(collectionView: UICollectionView) -> Double {
        return (Double(collectionView.bounds.size.width) - (ROW_COUNT * CELL_WIDTH)) / 4.0
    }
    
    // MARK: - public
    
    func updateFriendsComplete() {
        refreshHeaderView!.refreshScrollViewDataSourceDidFinishedLoading(collectionView)
        collectionView.reloadData()
    }
    
    // MARK: - IB
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationController = self.navigationController {
            navigationController.navigationBarHidden = false
        }
        
        self.edgesForExtendedLayout = UIRectEdge.None

        if refreshHeaderView == nil {
            var view = PZPullToRefreshView(frame: CGRectMake(0, 0 - collectionView.bounds.size.height, collectionView.bounds.size.width, collectionView.bounds.size.height))
            view.delegate = self
            collectionView.addSubview(view)
            refreshHeaderView = view
        }

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
                cell.messageCount = friend.unreadCount
                return cell;
            }
            .ce_DidScroll { (scrollView) -> Void in
                refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
            }.ce_DidEndDragging { (scrollView, decelerate) -> Void in
                refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
            }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendsComplete", name: kNotification_UpdateFriendsComplete, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserInfo.shared.isUpdatingFriends {
            refreshHeaderView?.state = .Loading
            collectionView.setContentOffset(CGPointMake(0, -refreshHeaderView!.thresholdValue), animated: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: CELL_WIDTH, height: CELL_HEIGHT)
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return CGFloat(getCellSpacing(collectionView))
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        let i = CGFloat(getCellSpacing(collectionView))
//        return UIEdgeInsets(top: i, left: i, bottom: i, right: i)
//    }
    
    // MARK: - UICollectionViewDataSource
    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return UserInfo.shared.friends.count
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
//        let friend = UserInfo.shared.friends[indexPath.row]
//        if let appUser = friend.appUser {
//            cell.iconImageUrl = appUser.iconUrl
//            cell.nickname = appUser.nickname
//        }
//        else if let partnerUser = friend.partnerUser {
//            cell.iconImageUrl = partnerUser.iconUrl
//            cell.nickname = partnerUser.name
//        }
//        else {
//            cell.iconImageUrl = nil
//            cell.nickname = nil
//        }
//        cell.messageCount = friend.unreadCount
//        return cell;
//    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - PZPullToRefreshDelegate
    
//    func pullToRefreshDidTrigger(view: PZPullToRefreshView) -> () {
//        UserInfo.shared.updateFriends()
//    }
//    
//    func pullToRefreshIsLoading(view: PZPullToRefreshView) -> Bool {
//        return UserInfo.shared.isUpdatingFriends
//    }
//    
//    func pullToRefreshLastUpdated(view: PZPullToRefreshView) -> NSDate {
//        return NSDate()
//    }
}