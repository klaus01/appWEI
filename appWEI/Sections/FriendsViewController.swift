//
//  FriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PZPullToRefreshDelegate {
    
    private var refreshHeaderView: PZPullToRefreshView?
    
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendsComplete", name: kNotification_UpdateFriendsComplete, object: nil)
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserInfo.shared.isUpdatingFriends {
            refreshHeaderView?.state = .Loading
            collectionView.setContentOffset(CGPointMake(0, -refreshHeaderView!.thresholdValue), animated: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let i = ((collectionView.bounds.width - 300) / 3) / 2
        return UIEdgeInsets(top: i, left: i, bottom: i, right: i)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserInfo.shared.friends.count//friends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    
    // MARK: - UICollectionViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    // MARK: - PZPullToRefreshDelegate
    
    func pullToRefreshDidTrigger(view: PZPullToRefreshView) -> () {
        UserInfo.shared.updateFriends()
    }
    
    func pullToRefreshIsLoading(view: PZPullToRefreshView) -> Bool {
        return UserInfo.shared.isUpdatingFriends
    }
    
    func pullToRefreshLastUpdated(view: PZPullToRefreshView) -> NSDate {
        return NSDate()
    }
}