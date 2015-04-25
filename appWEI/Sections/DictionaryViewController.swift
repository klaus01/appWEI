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
    private var words: [WordModel] = [WordModel]()
    private var allLoaded = false
    private var searchType = SearchType.Number
    private var selectedWord: WordModel?
    
    @IBOutlet weak var searchTypeButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchTypeButton()
        self.setupSearchTextField()
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
        tableView.rowHeight = WordTableViewCell.cellHeight
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
                cell.rightText = word.description
                
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
        let offset = words.count
        if searchTextField.text == nil || searchTextField.text!.length <= 0 {
            ServerHelper.wordFindByAppUser(offset: offset, resultCount: pageCount, completionHandler: completionHandler)
        }
        else if searchType == .Number {
            ServerHelper.wordFindByAppUser(number: searchTextField.text!, offset: offset, resultCount: pageCount, completionHandler: completionHandler)
        }
        else {
            ServerHelper.wordFindByAppUser(description: searchTextField.text!, offset: offset, resultCount: pageCount, completionHandler: completionHandler)
        }
    }
    
}
