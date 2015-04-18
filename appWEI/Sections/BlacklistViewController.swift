//
//  BlacklistViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/18.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class BlacklistViewController: UIViewController {

    private var blacklist = [FriendModel]()
//    private let refreshControl = UIRefreshControl()
    
    private func refreshBlacklist() {
        blacklist = UserInfo.shared.friends.filter { (friend) -> Bool in
            return friend.isBlack
        }
    }
    
//    func updateFriendsComplete() {
//        refreshBlacklist()
//        collectionView.reloadData()
//        refreshControl.endRefreshing()
//    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshBlacklist()
        
//        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
//        refreshControl.pulled { () -> () in
//            UserInfo.shared.updateFriends()
//        }
//        collectionView.addSubview(refreshControl)
        
        let cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
            .ce_NumberOfItemsInSection { [unowned self] (collectionView, section) -> Int in
                return self.blacklist.count
            }
            .ce_CellForItemAtIndexPath { [unowned self] (collectionView, indexPath) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
                let friend = self.blacklist[indexPath.row]
                
                cell.iconImageUrl = friend.iconUrl
                cell.nickname = friend.nickname
                cell.hintText = nil
                cell.deleteAction = { (cell) -> Void in
                    if let indexPath = collectionView.indexPathForCell(cell) {
                        let finder = self.blacklist.removeAtIndex(indexPath.row)
                        collectionView.deleteItemsAtIndexPaths([indexPath])
                        ServerHelper.appUserSetFriendIsBlack(finder.userID!, isBlack: false, completionHandler: { (ret, error) -> Void in
                            if let error = error {
                                println(error)
                                return
                            }
                            UserInfo.shared.updateFriends()
                        })
                    }
                }
                return cell;
        }
        setUserListStyleWithCollectionView(collectionView)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendsComplete", name: kNotification_UpdateFriendsComplete, object: nil)
    }
    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        if UserInfo.shared.isUpdatingFriends {
//            refreshControl.beginRefreshing()
//        }
//    }
    
}
