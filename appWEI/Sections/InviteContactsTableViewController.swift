//
//  InviteContactsTableViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import AddressBook

class InviteContactsTableViewController: UITableViewController {
    
    // MARK: - private
    
    private var firstLetterArray = [String]()
    private var contacts = [String : [[String : AnyObject]]]()
    
    private func getSysContacts() -> [[String: AnyObject]] {
        var error:Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
        
        if sysAddressBookStatus == .Denied || sysAddressBookStatus == .NotDetermined {
            // Need to ask for authorization
            var authorizedSingal:dispatch_semaphore_t = dispatch_semaphore_create(0)
            var askAuthorization:ABAddressBookRequestAccessCompletionHandler = { success, error in
                if success {
                    ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
                    dispatch_semaphore_signal(authorizedSingal)
                }
            }
            ABAddressBookRequestAccessWithCompletion(addressBook, askAuthorization)
            dispatch_semaphore_wait(authorizedSingal, DISPATCH_TIME_FOREVER)
        }
        
        return analyzeSysContacts( ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray )
    }
    
    private func analyzeSysContacts(sysContacts: NSArray) -> [[String:AnyObject]] {
        
        
        func analyzeContactProperty(contact: ABRecordRef, property: ABPropertyID) -> [String]? {
            var propertyValues:ABMultiValueRef? = ABRecordCopyValue(contact, property)?.takeRetainedValue()
            if propertyValues != nil {
                var values = [String]()
                for i in 0 ..< ABMultiValueGetCount(propertyValues) {
                    var value = ABMultiValueCopyValueAtIndex(propertyValues, i)
                    var val = value.takeRetainedValue() as? String ?? ""
                    values.append(val)
                }
                return values
            }else{
                return nil
            }
        }
        
        var allContacts = [[String:AnyObject]]()
        for contact in sysContacts {
            // 姓
            let firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as? String ?? ""
            // 名
            let lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as? String ?? ""
            // 电话
            var phones = analyzeContactProperty(contact, kABPersonPhoneProperty)
            if let phones = phones {
                for phone in phones {
                    var currentContact = [String:String]()
                    currentContact["name"] = (lastName + firstName).trimmed()
                    currentContact["phone"] = phone
                        .replace("+", withString: "")
                        .replace("-", withString: "")
                        .replace("(", withString: "")
                        .replace(")", withString: "")
                        // 以下两个空格是不同的(有一个是空格，另一个是不可见字符)
                        .replace(" ", withString: "")
                        .replace(" ", withString: "")
                    allContacts.append(currentContact)
                }
            }
        }
        return allContacts
    }
    
    // MARK: - public
    
    func addFriendButtonClick(Sender: UIButton) {
        let cell = Sender.superview!.superview! as! UITableViewCell
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let firstLetter = self.firstLetterArray[indexPath.section]
            var contacts = self.contacts[firstLetter]!
            var contact = contacts[indexPath.row]
            
            contact["networking"] = true
            contacts[indexPath.row] = contact
            self.contacts[firstLetter] = contacts
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            
            ServerHelper.appUserAddFriend(contact["phone"] as! String, completionHandler: { (ret, error) -> Void in
                contact["networking"] = false
                if error != nil {
                    println(error)
                }
                else {
                    contact["isFriend"] = ret!.success
                }
                contacts[indexPath.row] = contact
                self.contacts[firstLetter] = contacts
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            })
            
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let allContacts = getSysContacts()
        allContacts.map { contact -> [String : AnyObject] in
            var ret = contact
            
            // 生成姓名拼音，确定分组
            let name = ret["name"] as! String
            let py = name.getPinYin().trimmed()
            let firstLetter = (py.length > 0 ? py[0]! : name[0]!).uppercaseString
            if let tContacts = self.contacts[firstLetter] {
            }
            else {
                self.firstLetterArray.append(firstLetter)
                self.contacts[firstLetter] = [[String : AnyObject]]()
            }
            
            // 是否已经是朋友了
            let phone = ret["phone"] as! String
            let friends = UserInfo.shared.friends.filter { FriendModel -> Bool in
                if let user = FriendModel.appUser {
                    return user.phoneNumber == phone
                }
                return false
            }
            ret["networking"] = false
            ret["isFriend"] = friends.count > 0
            
            self.contacts[firstLetter]!.append(ret)
            
            return ret
        }
        self.firstLetterArray.sort { (v1, v2) -> Bool in
            return v1 < v2
        }
    }

    // MARK: - Table view data source
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.firstLetterArray
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.firstLetterArray.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let firstLetter = self.firstLetterArray[section]
        let contacts = self.contacts[firstLetter]!
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.firstLetterArray[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let firstLetter = self.firstLetterArray[indexPath.section]
        let contacts = self.contacts[firstLetter]!
        let contact = contacts[indexPath.row]
        let phone = contact["phone"]! as! String
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! UITableViewCell
        let imageView = cell.viewWithTag(101) as! UIImageView
        let nameLabel = cell.viewWithTag(102) as! UILabel
        let nicknameLabel = cell.viewWithTag(103) as! UILabel
        let button = cell.viewWithTag(104) as! UIButton
        
        imageView.hidden = true
        nameLabel.text = contact["name"] as? String
        nicknameLabel.text = phone
        button.addTarget(self, action: "addFriendButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if getPhoneNumberAreaType(phone) == PhoneNumberAreaType.error {
            button.setTitle("不支持该手机号", forState: UIControlState.Normal)
            button.enabled = false
        }
        else if contact["isFriend"] as! Bool {
            button.setTitle("已添加", forState: UIControlState.Normal)
            button.enabled = false
        }
        else if contact["networking"] as! Bool {
            button.setTitle("正在添加...", forState: UIControlState.Normal)
            button.enabled = false
        }
        else {
            button.setTitle("添加", forState: UIControlState.Normal)
            button.enabled = true
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
