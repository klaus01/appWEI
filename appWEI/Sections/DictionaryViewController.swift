//
//  DictionaryViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class DictionaryViewController: UIViewController {

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
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchTypeButton()
        self.setupSearchTextField()
        self.setupTableView()
    }
    
    private func setupSearchTypeButton() {
        searchTypeButton.clicked { [weak self] (button) -> Void in
            self!.searchType = self!.searchType == .Number ? .Description : .Number
            button.setTitle(self!.searchType == .Number ? "编号" : "描述", forState: UIControlState.Normal)
        }
    }
    
    private func setupSearchTextField() {
        searchTextField.ce_ShouldReturn { [weak self] (textField) -> Bool in
            self!.words.removeAll(keepCapacity: false)
            self!.allLoaded = false
            self!.tableView.reloadData()
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
                    cell.rightText = word.description
                    
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
        if searchTextField.text == nil || searchTextField.text!.length <= 0 {
            ServerHelper.wordFindByAppUser(offset: words.count, resultCount: pageCount, completionHandler: completionHandler)
        }
        else if searchType == .Number {
            ServerHelper.wordFindByAppUser(number: searchTextField.text!, offset: words.count, resultCount: pageCount, completionHandler: completionHandler)
        }
        else {
            ServerHelper.wordFindByAppUser(description: searchTextField.text!, offset: words.count, resultCount: pageCount, completionHandler: completionHandler)
        }
    }
    
}
