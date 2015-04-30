//
//  PartnerMessagesViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/30.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class PartnerMessagesViewController: UIViewController {

    private var messages: [HistoryMessageModel]?
    
    @IBOutlet weak var tableView: UITableView!
    
    var partner: PartnerUserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false;
        
        setupTableView()
        
        ServerHelper.messageGetByPartnerUser(partner.partnerUserID, completionHandler: { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if let weakSelf = self {
                if ret!.success {
                    self!.messages = ret!.data
                    self!.tableView.reloadData()
                }
                else {
                    UIAlertView.showMessage(ret!.errorMessage!)
                }
            }
        })
    }
    
    private func setupTableView() {
        var cellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "LOADING")
        cellNib = UINib(nibName: "PartnerMessageTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "MYCELL")
        tableView.rowHeight = 147
        tableView
        .ce_NumberOfRowsInSection { [weak self] (tableView, section) -> Int in
            return self!.messages == nil ? 1 : self!.messages!.count
        }
        .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
            if self!.messages == nil {
                return tableView.dequeueReusableCellWithIdentifier("LOADING", forIndexPath: indexPath) as! UITableViewCell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! PartnerMessageTableViewCell
                cell.message = self!.messages![indexPath.row]
                return cell
            }
        }
    }
    
}
