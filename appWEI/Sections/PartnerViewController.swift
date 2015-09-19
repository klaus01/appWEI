//
//  PartnerViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/29.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class PartnerViewController: UIViewController {

    enum ListType {
        case Partner
        case Message
    }
    private var partners: [PartnerUserModel]!
    private var partnerMessages: [PartnerUserAndMessageOverviewModel]! {
        didSet {
            if let list = partnerMessages {
                var count = 0
                for partnerMessage in partnerMessages {
                    if let messageInfo = partnerMessage.messageOverview {
                        count += (messageInfo.unreadCount + messageInfo.noAwardCount)
                    }
                }
                messageCount = count
            }
            else {
                messageCount = 0
            }
        }
    }
    private var selectedPartner: PartnerUserModel?
    private var listType: ListType = .Partner {
        didSet {
            partnerListBottomView.hidden = listType != .Partner
            partnerTableView.hidden      = listType != .Partner
            messageListBottomView.hidden = listType != .Message
            messageCollectionView.hidden = listType != .Message
        }
    }
    private var messageCount = 0 {
        didSet {
            messageCountLabel.hidden = messageCount <= 0
            messageCountLabel.text = "\(messageCount)"
        }
    }
    
    @IBOutlet weak var partnerListButton: UIButton!
    @IBOutlet weak var messageListButton: UIButton!
    @IBOutlet weak var partnerListBottomView: UIView!
    @IBOutlet weak var messageListBottomView: UIView!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    @IBOutlet weak var partnerTableView: UITableView!
    @IBOutlet weak var messageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listType = .Partner
        messageCount = 0
        setupListButton()
        setupPartnerTableView()
        setupMessageCollectionView()
        loadPartners()
        loadPartnerMessages()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is PartnerMessagesViewController {
            (segue.destinationViewController as! PartnerMessagesViewController).partner = selectedPartner
        }
    }
    
    private func setupListButton() {
        partnerListButton.clicked { [weak self] btn -> () in
            self!.listType = .Partner
        }
        messageListButton.clicked { [weak self] btn -> () in
            self!.listType = .Message
        }
        messageCountLabel.layer.cornerRadius = 10
    }
    
    private func setupPartnerTableView() {
        let cellNib = UINib(nibName: "PartnerTableViewCell", bundle: nil)
        partnerTableView.registerNib(cellNib, forCellReuseIdentifier: "MYCELL")
        let loadingCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        partnerTableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LOADING")
        partnerTableView.rowHeight = PartnerTableViewCell.cellHeight
        partnerTableView
        .ce_NumberOfRowsInSection { [weak self] (tableView, section) -> Int in
            return (self!.partners == nil || self!.partnerMessages == nil) ? 1 : self!.partners.count
        }
        .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
            if self!.partners == nil || self!.partnerMessages == nil {
                return tableView.dequeueReusableCellWithIdentifier("LOADING", forIndexPath: indexPath) as! UITableViewCell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! PartnerTableViewCell
                let partner = self!.partners[indexPath.row]
                cell.pictureImageUrl = partner.iconUrl
                cell.title = partner.name
                cell.desc = partner.description
                if self!.isSubscribedWithPartner(partner.partnerUserID) {
                    cell.subscribe = nil
                }
                else {
                    cell.subscribe = { [weak self] cell -> () in
                        cell.subscribe = nil
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
                }
                return cell
            }
        }
    }
    
    private func setupMessageCollectionView() {
        var cellNib = UINib(nibName: "LoadingCollectionViewCell", bundle: nil)
        messageCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "LOADING")
        cellNib = UINib(nibName: "PartnerCollectionViewCell", bundle: nil)
        messageCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        messageCollectionView
        .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
            return (self!.partners == nil || self!.partnerMessages == nil) ? 1 : self!.partnerMessages.count
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            if self!.partners == nil || self!.partnerMessages == nil {
                return collectionView.dequeueReusableCellWithReuseIdentifier("LOADING", forIndexPath: indexPath) as! UICollectionViewCell
            }
            else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! PartnerCollectionViewCell
                let partnerMessage = self!.partnerMessages[indexPath.item]
                
                cell.iconImageUrl = partnerMessage.partnerUser.iconUrl
                cell.nickname     = partnerMessage.partnerUser.name
                cell.hintType     = .None
                if let messageInfo = partnerMessage.messageOverview {
                    if messageInfo.unreadCount > 0 {
                        cell.hintType = .NewMessage
                    }
                    else if messageInfo.noAwardCount > 0 {
                        cell.hintType = .Prize
                    }
                }
                
                return cell
            }
        }
        .ce_DidSelectItemAtIndexPath { [weak self] (collectionView, indexPath) -> Void in
            if self!.partners == nil || self!.partnerMessages == nil {
            }
            else {
                self!.selectedPartner = self!.partnerMessages[indexPath.item].partnerUser
                self!.performSegueWithIdentifier("showPartnerMessages", sender: nil)
            }
        }
        .setUserListStyle()
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
