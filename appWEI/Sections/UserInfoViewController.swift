//
//  UserInfoViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/24.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - private
    
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
        println("selectImageByPhotoLibrary")
    }
    
    // MARK: - IB
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!

    @IBAction func iconButtonClick(sender: AnyObject) {
        UIActionSheet(title: "选择头像", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍一张", "从手机相册中选择", "选择默认头像").showInView(self.view)
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
        iconButton.setBackgroundImage(image, forState: UIControlState.Normal)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
