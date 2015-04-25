//
//  StatisticsViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/21.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    enum SearchType {
        case Number
        case Description
    }
    private let pageCount = 20
    private var words: [WordModel] = [WordModel]()
    private var allLoaded = false
    private var searchType = SearchType.Number
    private var selectedWord: WordModel?
    
    @IBOutlet weak var searchTypeButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var orderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchTypeButton()
        self.setupSearchTextField()
        self.setupOrderSegmentedControl()
        self.setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let word = selectedWord {
            if segue.destinationViewController is WordViewController {
                (segue.destinationViewController as! WordViewController).word = word
            }
        }
    }
    
    private func setupSearchTypeButton() {
        searchTypeButton.clicked { [weak self] (button) -> Void in
            self!.searchType = self!.searchType == .Number ? .Description : .Number
            button.setTitle(self!.searchType == .Number ? "编号" : "描述", forState: UIControlState.Normal)
        }
    }
    
    private func setupOrderSegmentedControl() {
        orderSegmentedControl.selectedIndexChange() { [weak self] (index) -> Void in
            self!.reloadWords()
        }
    }
    
    private func setupSearchTextField() {
        searchTextField.ce_ShouldReturn { [weak self] (textField) -> Bool in
            self!.reloadWords()
            textField.resignFirstResponder()
            return true
        }
    }
    
    private func setupTableView() {
        let cellNib = UINib(nibName: "WordTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "MYCELL")
        let loadingCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LOADINGCELL")
        tableView
        .ce_NumberOfSectionsIn { [weak self] (tableView) -> Int in
            return 1 + (self!.allLoaded ? 0 : 1)
        }
        .ce_NumberOfRowsInSection { [weak self] (tableView, section) -> Int in
            return section == 0 ? self!.words.count : 1
        }
        .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! WordTableViewCell
                let word = self!.words[indexPath.item]
                
                cell.number = word.number
                cell.pictureImageUrl = word.pictureUrl
                let orderType = self!.orderSegmentedControl.selectedSegmentIndex
                var text = ""
                switch getPhoneNumberAreaType(UserInfo.shared.phoneNumber!) {
                case .CN:
                    switch orderType {
                    case 0:
                        text = "\(word.useCount_Before1D_CN)"
                    case 1:
                        text = "\(word.useCount_Before30D_CN)"
                    default:
                        text = "\(word.useCount_Before365D_CN)"
                    }
                case .HK:
                    switch orderType {
                    case 0:
                        text = "\(word.useCount_Before1D_HK)"
                    case 1:
                        text = "\(word.useCount_Before30D_HK)"
                    default:
                        text = "\(word.useCount_Before365D_HK)"
                    }
                default:
                    break
                }
                cell.rightText = "\t\t\(text)"

                return cell
            }
            else {
                return tableView.dequeueReusableCellWithIdentifier("LOADINGCELL", forIndexPath: indexPath) as! UITableViewCell
            }
        }
        .ce_DidSelectRowAtIndexPath { [weak self] (tableView, indexPath) -> Void in
            if indexPath.section == 0 {
                self!.selectedWord = self!.words[indexPath.item]
                self!.performSegueWithIdentifier("showWord", sender: nil)
            }
        }
        .ce_WillDisplayCell { [weak self] (tableView, cell, indexPath) -> Void in
            if !(self!.allLoaded) && indexPath.section == 1 {
                self!.loadMoreWords()
            }
        }
    }
    
    private func reloadWords() {
        words.removeAll(keepCapacity: false)
        allLoaded = false
        tableView.reloadData()
    }
    
    private func loadMoreWords() {
        let completionHandler = { [weak self] (ret: ServerResultModel<[WordModel]>?, error: NSError?) -> Void in
            if let error = error {
                println(error)
                return
            }
            if ret!.success {
                if let weakSelf = self, let data = ret!.data {
                    if data.count < self!.pageCount {
                        self!.allLoaded = true
                    }
                    if data.count > 0 {
                        self!.words += data
                    }
                    self!.tableView.reloadData()
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
        let orderType = orderSegmentedControl.selectedSegmentIndex
        let offset = words.count
        if searchTextField.text == nil || searchTextField.text!.length <= 0 {
            ServerHelper.wordFindAll(orderType, offset: offset, resultCount: pageCount, completionHandler: completionHandler)
        }
        else if searchType == .Number {
            ServerHelper.wordFindAll(orderType, number: searchTextField.text!, offset: offset, resultCount: pageCount, completionHandler: completionHandler)
        }
        else {
            ServerHelper.wordFindAll(orderType, description: searchTextField.text!, offset: offset, resultCount: pageCount, completionHandler: completionHandler)
        }
    }
    
}
