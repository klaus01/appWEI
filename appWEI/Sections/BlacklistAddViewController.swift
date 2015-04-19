//
//  BlacklistAddViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/19.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class BlacklistAddViewController: UIViewController {
    
    enum UserSelectMode: Int {
        case Radio = 0
        case Multiple
    }
    
    private var whitelist: [FriendModel]!
    private var selectedUserIDs = [Int]()
    private let refreshControl = UIRefreshControl()
    private var userSelectMode = UserSelectMode.Radio {
        didSet {
            if userSelectMode == .Radio {
                self.navigationItem.setRightBarButtonItem(nil, animated: true)
            }
            else {
                let buttonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Bordered) { [weak self] barButtonItem -> () in
                    println(self!.selectedUserIDs)
                }
                self.navigationItem.setRightBarButtonItem(buttonItem, animated: true)
            }
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.pulled { () -> () in
            UserInfo.shared.updateFriends()
        }
        collectionView.addSubview(refreshControl)
    }
    private func setupCollectionView() {
        let cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        collectionView
            .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
                return self!.whitelist.count
            }
            .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
                let friend = self!.whitelist[indexPath.row]
                
                cell.backgroundColor = self!.selectedUserIDs.indexOf(friend.userID!) == nil ? cell.backgroundColor : UIColor.redColor()
                cell.iconImageUrl = friend.iconUrl
                cell.nickname = friend.nickname
                cell.hintText = nil
                cell.deleteAction = nil
                cell.clicked = { [weak self] (cell) -> Void in
                    if self!.userSelectMode == .Radio {
                        UIAlertView.yesOrNo("要将此好友加入黑名单吗？", didDismiss: { [weak self] (isYes) -> Void in
                            if !isYes {
                                return
                            }
                            let indexPath = collectionView.indexPathForCell(cell)!
                            var friend = self!.whitelist[indexPath.row]
                            ServerHelper.appUserSetFriendIsBlack(friend.userID!, isBlack: true, completionHandler: { (ret, error) -> Void in
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
                        })
                    }
                    else {
                        let indexPath = collectionView.indexPathForCell(cell)!
                        let friend = self!.whitelist[indexPath.row]
                        if self!.selectedUserIDs.indexOf(friend.userID!) == nil {
                            self!.selectedUserIDs.push(friend.userID!)
                        }
                        else {
                            self!.selectedUserIDs.remove(friend.userID!)
                        }
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                    }
                }
                cell.longPressAction = { [weak self] (cell) -> Void in
                    if self!.userSelectMode == .Multiple {
                        return
                    }
                    self!.userSelectMode = .Multiple
                    
                    let indexPath = collectionView.indexPathForCell(cell)!
                    self!.selectedUserIDs.push(self!.whitelist[indexPath.row].userID!)
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
                return cell;
            }
        setUserListStyleWithCollectionView(collectionView)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        whitelist = UserInfo.shared.whitelistFriends

        setupRefreshControl()
        setupCollectionView()
        self.ce_addObserverForName(kNotification_UpdateFriendsComplete) { [weak self] (notification) -> Void in
            self!.whitelist = UserInfo.shared.whitelistFriends
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
