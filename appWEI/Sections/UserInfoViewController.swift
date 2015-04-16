//
//  UserInfoViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/24.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Private func
    
    private func showSelectIconActionSheet() {
        UIActionSheet(title: "选择头像", cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍一张", "从手机相册中选择", "选择默认头像")
            .clicked({ (buttonAtIndex) -> () in
                switch buttonAtIndex {
                case 1:
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.allowsEditing = true
                    imagePickerController.sourceType = .Camera
                    imagePickerController.ce_DidFinishPickingMediaWithInfo({ (picker, info) -> Void in
                        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                            self.iconImage = image
                            picker.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                case 2:
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.allowsEditing = true
                    imagePickerController.sourceType = .PhotoLibrary
                    imagePickerController.ce_DidFinishPickingMediaWithInfo({ (picker, info) -> Void in
                        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                            self.iconImage = image
                            picker.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                case 3:
                    self.performSegueWithIdentifier("userToDefaultIcon", sender: self)
                default:
                    return
                }
            })
            .showInView(self.view)
    }
    
    // MARK: - Public func
    
    var iconImage: UIImage? {
        get {
            return iconButton.backgroundImageForState(UIControlState.Normal)
        }
        set {
            iconButton.setBackgroundImage(newValue, forState: UIControlState.Normal)
        }
    }
    
    var isMen: Bool? {
        get {
            switch sexSegmentedControl.selectedSegmentIndex {
            case 0: return true
            case 1: return false
            default: return nil
            }
        }
        set {
            if newValue == nil {
                sexSegmentedControl.selectedSegmentIndex = -1
            }
            else {
                sexSegmentedControl.selectedSegmentIndex = newValue! ? 0 : 1
            }
        }
    }
    
    // MARK: - IB
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        iconButton.clicked { UIButton -> () in
            self.showSelectIconActionSheet()
        }
        saveButton.clicked { UIButton -> () in
            if self.iconImage == nil {
                UIAlertView.showMessage("请选择头像") { () -> Void in
                    self.showSelectIconActionSheet()
                }
                return
            }
            if self.nicknameTextField.text == nil || self.nicknameTextField.text!.length <= 0 {
                UIAlertView.showMessage("请输入昵称") { () -> Void in
                    self.nicknameTextField.becomeFirstResponder()
                }
                return
            }
            if self.nicknameTextField.text!.length > 1 {
                UIAlertView.showMessage("昵称只能输入一个字") { () -> Void in
                    self.nicknameTextField.becomeFirstResponder()
                }
                return
            }
            if self.isMen == nil {
                UIAlertView.showMessage("请选择性别")
                return
            }
            
            self.saveButton.enabled = false
            ServerHelper.appUserUpdate(UIImagePNGRepresentation(self.iconImage!), nickname: self.nicknameTextField.text!, isMan: self.isMen!) { (ret, error) -> Void in
                self.saveButton.enabled = true
                if let error = error {
                    println(error)
                    return
                }
                if ret!.success {
                    self.performSegueWithIdentifier("userToShow", sender: nil)
                }
                else {
                    UIAlertView.showMessage(ret!.errorMessage!)
                }
            }
        }
    }

}
