//
//  SelectFriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class SelectFriendsViewController: UIViewController {

    var selectedFriends: [FriendModel]!
    var popViewControllerBlock: ((SelectFriendsViewController) -> ())?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;

        setupTableView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for item in selectedFriends {
            var i = 0
            for friend in UserInfo.shared.friends {
                if friend.userID == item.userID {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                    break
                }
                i++
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedFriends.removeAll(keepCapacity: false)
        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            for indexPath in indexPaths {
                selectedFriends.append(UserInfo.shared.friends[indexPath.row])
            }
        }
        
        if let f = popViewControllerBlock {
            f(self)
        }
    }
    
    private func setupTableView() {
        tableView
        .ce_NumberOfRowsInSection { (tableView, section) -> Int in
            return UserInfo.shared.friends.count
        }
        .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
            let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! UITableViewCell
            let friend = UserInfo.shared.friends[indexPath.row]
            cell.imageView?.imageWebUrl = friend.iconUrl
            cell.textLabel?.text = friend.nickname
            return cell
        }
    }
    
}
