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
    private var words = [WordModel]()
    private var allLoaded = false
    private var searchType = SearchType.Number
    
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
        tableView.ce_NumberOfRowsInSection { [weak self] (tableView, section) -> Int in
            return self!.getWordCount()
            }
            .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
                if !(self!.allLoaded) && self!.getWordCount() == (indexPath.row + 1) {
                    return tableView.dequeueReusableCellWithIdentifier("LOADINGCELL", forIndexPath: indexPath) as! UITableViewCell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! WordTableViewCell
                    let word = self!.words[indexPath.row]
                    
                    cell.number = word.number
                    cell.pictureImageUrl = word.pictureUrl
                    let orderType = self!.orderSegmentedControl.selectedSegmentIndex
                    switch getPhoneNumberAreaType(UserInfo.shared.phoneNumber!) {
                    case .CN:
                        switch orderType {
                        case 0:
                            cell.rightText = "\(word.useCount_Before1D_CN)"
                        case 1:
                            cell.rightText = "\(word.useCount_Before30D_CN)"
                        default:
                            cell.rightText = "\(word.useCount_Before365D_CN)"
                        }
                    case .HK:
                        switch orderType {
                        case 0:
                            cell.rightText = "\(word.useCount_Before1D_HK)"
                        case 1:
                            cell.rightText = "\(word.useCount_Before30D_HK)"
                        default:
                            cell.rightText = "\(word.useCount_Before365D_HK)"
                        }
                    default:
                        break
                    }

                    return cell
                }
            }
            .ce_DidSelectRowAtIndexPath { [weak self] (tableView, indexPath) -> Void in
                if (self!.allLoaded) || self!.getWordCount() != (indexPath.row + 1) {
                    println("选中了\(indexPath)")
                    // TODO 进入字界面
                }
            }
            .ce_WillDisplayCell { [weak self] (tableView, cell, indexPath) -> Void in
                if self!.getWordCount() == (indexPath.row + 1) {
                    self!.loadMoreWords()
                }
        }
    }
    
    private func getWordCount() -> Int {
        return words.count + (allLoaded ? 0 : 1)
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
                    if data.count > 0 {
                        self!.words += data
                    }
                    else {
                        self!.allLoaded = true
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
