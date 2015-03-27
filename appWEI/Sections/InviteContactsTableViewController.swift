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
    
    private var phones: [[String: String]]!
    
    func getSysContacts() -> [[String: String]] {
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
    
    func analyzeSysContacts(sysContacts: NSArray) -> [[String:String]] {
        
        
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
        
        var allContacts:Array = [[String:String]]()
        for contact in sysContacts {
            var currentContact:Dictionary = [String:String]()
            // 姓
            let firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as? String ?? ""
            // 名
            let lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as? String ?? ""
            // 电话
            var phones = analyzeContactProperty(contact, kABPersonPhoneProperty)
            if let phones = phones {
                for phone in phones {
                    currentContact["firstName"] = firstName
                    currentContact["lastName"] = lastName
                    currentContact["phone"] = phone
                }
            }
            allContacts.append(currentContact)
        }
        return allContacts
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phones = getSysContacts()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.phones.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let phone = phones[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("MYCELL", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = phone["firstName"]! + phone["lastName"]! + " " + phone["phone"]!
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
