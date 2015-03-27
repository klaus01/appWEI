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
    
    private func selectImageByDefault() {
        self.performSegueWithIdentifier("userToDefaultIcon", sender: self)
    }
    
    private func takePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .Camera
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func selectImageByPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .PhotoLibrary
        self.presentViewController(imagePickerController, animated: true, completion: nil)
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

    @IBAction func iconButtonClick(sender: AnyObject) {
        UIActionSheet(title: "选择头像", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍一张", "从手机相册中选择", "选择默认头像").showInView(self.view)
    }
    
    @IBAction func saveClick(sender: AnyObject) {
        if iconImage == nil {
            UIAlertView.showMessage("请选择头像")
            return
        }
        if nicknameTextField.text == nil || nicknameTextField.text!.length <= 0 {
            UIAlertView.showMessage("请输入昵称")
            nicknameTextField.becomeFirstResponder()
            return
        }
        if nicknameTextField.text!.length > 1 {
            UIAlertView.showMessage("昵称只能输入一个字")
            nicknameTextField.becomeFirstResponder()
            return
        }
        if isMen == nil {
            UIAlertView.showMessage("请选择性别")
            return
        }
        
        saveButton.enabled = false
        ServerHelper.appUserUpdate(UIImagePNGRepresentation(iconImage!), nickname: nicknameTextField.text!, isMan: isMen!) { (ret, error) -> Void in
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
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    }

    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            takePhoto()
        case 2:
            selectImageByPhotoLibrary()
        case 3:
            selectImageByDefault()
        default:
            return
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        iconImage = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
