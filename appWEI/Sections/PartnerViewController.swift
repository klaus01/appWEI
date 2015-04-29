//
//  PartnerViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/29.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class PartnerViewController: UIViewController {

    private var partners: [PartnerUserModel]!
    private var partnerMessages: [PartnerUserAndMessageOverviewModel]!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var partnerTableView: UITableView!
    @IBOutlet weak var messageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        setupPartnerTableView()
        setupMessageCollectionView()
        loadPartners()
        loadPartnerMessages()
    }

    private func setupSegmentedControl() {
        segmentedControl.selectedIndexChange { [weak self] (index) -> () in
            self!.partnerTableView.hidden = index != 0
            self!.messageCollectionView.hidden = index != 1
        }
    }
    
    private func setupPartnerTableView() {
        let cellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        partnerTableView.registerNib(cellNib, forCellReuseIdentifier: "LOADING")
        partnerTableView
        .ce_NumberOfRowsInSection { [weak self] (tableView, section) -> Int in
            return (self!.partners == nil && self!.partnerMessages == nil) ? 1 : self!.partners.count
        }
        .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
            if self!.partners == nil && self!.partnerMessages == nil {
                return tableView.dequeueReusableCellWithIdentifier("LOADING", forIndexPath: indexPath) as! UITableViewCell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! UITableViewCell
                let partner = self!.partners[indexPath.row]
                
                cell.imageView!.imageWebUrl = partner.iconUrl
                cell.textLabel!.text        = partner.name
                cell.detailTextLabel!.text  = partner.description
                let button = UIButton(frame: CGRectMake(0, 0, 90, 30))
                button.backgroundColor = UIColor.redColor()
                button.setTitle("订阅", forState: UIControlState.Normal)
                button.setTitle("已订阅", forState: UIControlState.Disabled)
                button.enabled = !(self!.isSubscribedWithPartner(partner.partnerUserID))
                button.clicked { (button) -> () in
                    button.enabled = false
                    ServerHelper.appUserAddPartnerUser(partner.partnerUserID, completionHandler: { [weak self] (ret, error) -> Void in
                        if let error = error {
                            println(error)
                            return
                        }
                        if let weakSelf = self {
                            if ret!.success {
                                self!.loadPartnerMessages()
                                self!.share(partner)
                            }
                            else {
                                UIAlertView.showMessage(ret!.errorMessage!)
                            }
                        }
                    })
                }
                cell.accessoryView = button
                
                return cell
            }
        }
    }
    
    private func setupMessageCollectionView() {
        var cellNib = UINib(nibName: "LoadingCollectionViewCell", bundle: nil)
        messageCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "LOADING")
        cellNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        messageCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        messageCollectionView
        .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
            return (self!.partners == nil && self!.partnerMessages == nil) ? 1 : self!.partnerMessages.count
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            if self!.partners == nil && self!.partnerMessages == nil {
                return collectionView.dequeueReusableCellWithReuseIdentifier("LOADING", forIndexPath: indexPath) as! UICollectionViewCell
            }
            else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
                let partnerMessage = self!.partnerMessages[indexPath.item]
                
                cell.iconImageUrl = partnerMessage.partnerUser.iconUrl
                cell.nickname     = partnerMessage.partnerUser.name
                cell.deleteAction = nil
                if let messageInfo = partnerMessage.messageOverview {
                    cell.hintText = "\(messageInfo.unreadCount)"
                }
                else {
                    cell.hintText = ""
                }
                
                return cell
            }
        }
        setUserListStyleWithCollectionView(messageCollectionView)
    }
    
    private func loadPartners() {
        ServerHelper.partnerUserGetCanSubscribe { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if let weakSelf = self {
                if ret!.success {
                    self!.partners = ret!.data!
                    self!.partnerTableView.reloadData()
                    self!.messageCollectionView.reloadData()
                }
                else {
                    UIAlertView.showMessage(ret!.errorMessage!)
                }
            }
        }
    }
    
    private func loadPartnerMessages() {
        ServerHelper.partnerUserGetSubscribed { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if let weakSelf = self {
                if ret!.success {
                    self!.partnerMessages = ret!.data!
                    self!.partnerTableView.reloadData()
                    self!.messageCollectionView.reloadData()
                }
                else {
                    UIAlertView.showMessage(ret!.errorMessage!)
                }
            }
        }
    }
    
    private func isSubscribedWithPartner(partnerUserID: Int) -> Bool {
        if let list = partnerMessages {
            for item in partnerMessages {
                if item.partnerUser.partnerUserID == partnerUserID {
                    return true
                }
            }
        }
        return false
    }
    
    private func share(partner: PartnerUserModel) {
        UIActionSheet(title: "您已订阅\(partner.name)\n\n把这个酷毙的东西分享给其他人吧。", cancelButtonTitle: "下次再分享", destructiveButtonTitle: nil, otherButtonTitles: "分享到Facebook", "分享到Instagram", "分享到微信")
            .clicked({ (buttonAtIndex) -> () in
            })
            .showInView(self.view)
    }
    
}
