//
//  DictionaryViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class DictionaryViewController: UIViewController {

    private let pageCount = 20
    private var words = [WordModel]()
    
    private func loadMoreWords() {
        ServerHelper.wordFindByAppUser(offset: words.count, resultCount: pageCount) { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if ret!.success {
                if let weakSelf = self, let data = ret!.data {
                    self!.words += data
                    self!.tableView.reloadData()
                }
            }
            else {
                UIAlertView.showMessage(ret!.errorMessage!)
            }
        }
    }
    
    @IBOutlet weak var searchTypeButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMoreWords()
        
        let cellNib = UINib(nibName: "WordTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "MYCELL")
        tableView.ce_NumberOfRowsInSection { [weak self] (tableView, section) -> Int in
            return self!.words.count
        }
        .ce_CellForRowAtIndexPath { [weak self] (tableView, indexPath) -> UITableViewCell in
            let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! WordTableViewCell
            let word = self!.words[indexPath.row]
            
            cell.number = word.number
            cell.pictureImageUrl = word.pictureUrl
            cell.rightText = word.description
            
            return cell
        }
        .ce_DidSelectRowAtIndexPath { [weak self] (tableView, indexPath) -> Void in
            println("选中了\(indexPath)")
            // TODO 进入字界面
        }
        .ce_WillDisplayCell { [weak self] (tableView, cell, indexPath) -> Void in
            if self!.words.count == (indexPath.row + 1) {
                self!.loadMoreWords()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
