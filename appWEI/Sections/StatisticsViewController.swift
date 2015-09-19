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
    enum OrderType {
        case Today
        case Month
        case Year
    }
    private let pageCount = 20
    private var userPhoneNumberAreaType: PhoneNumberAreaType = .CN
    private var words: [WordModel] = [WordModel]()
    private var firstWordUseCount = 0
    private var allLoaded = false
    private var searchType = SearchType.Number
    private var selectedWord: WordModel?
    private var orderType: OrderType {
        get {
            if !todayLineView.hidden {
                return .Today
            }
            else if !monthLineView.hidden {
                return .Month
            }
            return .Year
        }
        set {
            todayLineView.hidden = newValue != .Today
            monthLineView.hidden = newValue != .Month
            yearLineView.hidden  = newValue != .Year
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var todayLineView: UIView!
    @IBOutlet weak var monthLineView: UIView!
    @IBOutlet weak var yearLineView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhoneNumberAreaType = getPhoneNumberAreaType(UserInfo.shared.phoneNumber!)
        orderType = .Month
        setupSearchTextField()
        setupOrderTypeButton()
        setupTableView()
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
    
    private func setupOrderTypeButton() {
        todayButton.clicked { [weak self] btn -> () in
            if self!.orderType != .Today {
                self!.orderType = .Today
                self!.reloadWords()
            }
        }
        monthButton.clicked { [weak self] btn -> () in
            if self!.orderType != .Month {
                self!.orderType = .Month
                self!.reloadWords()
            }
        }
        yearButton.clicked { [weak self] btn -> () in
            if self!.orderType != .Year {
                self!.orderType = .Year
                self!.reloadWords()
            }
        }
    }
    
    private func setupSearchTextField() {
        searchTextField.ce_ShouldReturn { [weak self] (textField) -> Bool in
            self!.searchType = .Description
            if textField.text =~ "^[0-9]+$" {
                self!.searchType = .Number
            }
            self!.reloadWords()
            textField.resignFirstResponder()
            return true
        }
    }
    
    private func setupTableView() {
        let cellNib = UINib(nibName: "StatisticsWordTableViewCell", bundle: nil)
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
                let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! StatisticsWordTableViewCell
                let word = self!.words[indexPath.row]
                
                cell.pictureImageUrl = word.pictureUrl
                cell.count = self!.getWordUseCount(word)
                cell.allCount = self!.firstWordUseCount

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
    
    private func getWordUseCount(word: WordModel) -> Int {
        switch userPhoneNumberAreaType {
        case .CN:
            switch orderType {
            case .Today:
                return word.useCount_Before1D_CN
            case .Month:
                return word.useCount_Before30D_CN
            default:
                return word.useCount_Before365D_CN
            }
        case .HK:
            switch orderType {
            case .Today:
                return word.useCount_Before1D_HK
            case .Month:
                return word.useCount_Before30D_HK
            default:
                return word.useCount_Before365D_HK
            }
        default:
            return 0
        }
    }
    
    private func reloadWords() {
        words.removeAll(keepCapacity: false)
        firstWordUseCount = 0;
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
                        if (self!.words.count <= 0 && data.count > 0) {
                            self!.firstWordUseCount = self!.getWordUseCount(data[0])
                        }
                        self!.words += data
                    }
                    self!.tableView.reloadData()
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
        let orderType = self.orderType.hashValue
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
