//
//  BlacklistViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/18.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class BlacklistViewController: UIViewController {

    private var blacklist: [FriendModel]!
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blacklist = UserInfo.shared.blacklistFriends
        
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.pulled { () -> () in
            UserInfo.shared.updateFriends()
        }
        collectionView.addSubview(refreshControl)
        
        let cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
            .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
                return self!.blacklist.count
            }
            .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
                let friend = self!.blacklist[indexPath.row]
                
                cell.iconImageUrl = friend.iconUrl
                cell.nickname = friend.nickname
                cell.hintText = nil
                cell.deleteAction = { [weak self] (cell) -> Void in
                    if let indexPath = collectionView.indexPathForCell(cell) {
                        let finder = self!.blacklist[indexPath.row]
                        ServerHelper.appUserSetFriendIsBlack(finder.userID!, isBlack: false, completionHandler: { (ret, error) -> Void in
                            if let error = error {
                                println(error)
                                return
                            }
                            if ret!.success {
                                UserInfo.shared.updateFriends()
                            }
                            else {
                                UIAlertView.showMessage(ret!.errorMessage!)
                            }
                        })
                    }
                }
                return cell;
        }
        setUserListStyleWithCollectionView(collectionView)
        
        self.ce_addObserverForName(kNotification_UpdateFriendsComplete) { [weak self] (notification) -> Void in
            self!.blacklist = UserInfo.shared.blacklistFriends
            self!.collectionView.reloadData()
            self!.refreshControl.endRefreshing()
        }
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
    
}
