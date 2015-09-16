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
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 19, 0, 0);
        
        let allContacts = getSysContacts()
        allContacts.map { contact -> [String : AnyObject] in
            var ret = contact
            let phone = ret["phone"] as! String
            if getPhoneNumberAreaType(phone) == .Error {
                return ret
            }
            
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
            let friends = UserInfo.shared.friends.filter { FriendModel -> Bool in
                if let user = FriendModel.appUser {
                    return user.phoneNumber == phone
                }
                return false
            }
            ret["networking"] = false
            ret["isFriend"] = friends.count > 0
            ret["nicknameLoading"] = false
            
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let firstLetter = self.firstLetterArray[indexPath.section]
        var contacts = self.contacts[firstLetter]!
        var contact = contacts[indexPath.row]
        if (contact["nickname"] as? String == nil) && (contact["nicknameLoading"] as! Bool == false) {
            contact["nicknameLoading"] = true
            contacts[indexPath.row] = contact
            self.contacts[firstLetter] = contacts
            
            let phone = contact["phone"]! as! String
            ServerHelper.appUserGet(phone, completionHandler: { [weak self] (ret, error) -> Void in
                if let obj = self {
                }
                else {
                    return
                }
                
                if error != nil {
                    println(error)
                    return
                }
                if ret!.success {
                    contact["nickname"] = ret!.data!.nickname
                    contact["iconUrl"] = ret!.data!.iconUrl
                    contacts[indexPath.row] = contact
                    self!.contacts[firstLetter] = contacts
                    
                    if self!.tableView.cellForRowAtIndexPath(indexPath) != nil {
                        self!.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    }
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let firstLetter = self.firstLetterArray[indexPath.section]
        let contacts = self.contacts[firstLetter]!
        let contact = contacts[indexPath.row]
        let phone = contact["phone"]! as! String
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! UITableViewCell
        
        if let imageView = cell.viewWithTag(101) as? UIImageView {
            imageView.layer.cornerRadius = imageView.bounds.size.width * 0.5
            if let iconUrl = contact["iconUrl"] as? String {
                imageView.imageWebUrl = iconUrl
            }
        }
        
        if let label = cell.viewWithTag(102) as? UILabel {
            var attrStr = NSMutableAttributedString()
            if let nickname = contact["nickname"] as? String {
                let attributes = [
                    NSFontAttributeName as NSObject : UIFont(name: "CloudMeiHeiGBK", size: 30) as! AnyObject,
                    NSForegroundColorAttributeName : UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                ]
                attrStr.appendAttributedString(NSAttributedString(string: "\(nickname) ", attributes: attributes))
            }
            if let name = contact["name"] as? String {
                let attributes = [
                    NSFontAttributeName as NSObject : UIFont(name: "Microsoft YaHei", size: 17) as! AnyObject,
                    NSForegroundColorAttributeName : UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
                ]
                attrStr.appendAttributedString(NSAttributedString(string: "(\(name))", attributes: nil))
            }
            label.attributedText = attrStr
        }
        
        if let button = cell.viewWithTag(104) as? UIButton {
            button.setImage(UIImage(named: "connected"), forState: UIControlState.Disabled)
            button.addTarget(self, action: "addFriendButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            if contact["isFriend"] as! Bool {
                button.enabled = false
            }
            else if contact["networking"] as! Bool {
                button.enabled = false
            }
            else {
                button.enabled = true
            }
        }
        
        if let lineView = cell.viewWithTag(105) {
            lineView.hidden = indexPath.row == (contacts.count - 1)
        }
        
        return cell
    }

}
