//
//  UserInfoViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/24.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

enum UserInfoViewControllerMode: Int {
    case newUser = 0
    case updateUser
}

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
                        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
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
                        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
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
    
    var mode: UserInfoViewControllerMode = .newUser
    
    var iconImage: UIImage? {
        get {
            return iconImageView.image
        }
        set {
            if let image = newValue {
                let MAXSIZE = CGFloat(300)
                let oldSize = image.size
                if oldSize.width > MAXSIZE || oldSize.height > MAXSIZE {
                    var newSize = CGSizeZero
                    if oldSize.width > oldSize.height {
                        newSize.width = MAXSIZE
                        newSize.height = oldSize.height * (newSize.width / oldSize.width)
                    }
                    else {
                        newSize.height = MAXSIZE
                        newSize.width = oldSize.width * (newSize.height / oldSize.height)
                    }
                    iconImageView.image = image.scaleToSize(newSize)
                    return
                }
            }
            iconImageView.image = newValue
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
    
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconView.layer.cornerRadius = 4
        iconView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        iconView.layer.shadowOffset = CGSizeMake(0, 2)
        iconView.layer.shadowOpacity = 1
        iconView.layer.shadowRadius = 4
        
        // 图片 上边左右角 圆角
//        let maskPath = UIBezierPath(roundedRect: iconImageView.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSizeMake(4, 4))
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = iconImageView.bounds;
//        maskLayer.path = maskPath.CGPath;
//        iconImageView.layer.mask = maskLayer;
        
        saveButton.backgroundColor = THEME_BAR_COLOR
        saveButton.setTitleColor(THEME_BAR_TEXT_COLOR, forState: UIControlState.Normal)
        
        iconImageView.addGestureRecognizer(UITapGestureRecognizer() { [unowned self] (gestureRecognizer) -> () in
            self.showSelectIconActionSheet()
        })
        
        nicknameTextField.ce_ShouldChangeCharactersInRange { (textField, range, string) -> Bool in
            if string == "\n" {
                if textField.text == nil || textField.text!.length <= 0 || textField.text!.length > 1 {
                    UIAlertView.showMessage("请输入一个字做为昵称")
                }
                else {
                    textField.resignFirstResponder()
                }
                return false
            }
            return true
        }
        
        saveButton.clicked { [unowned self] UIButton -> () in
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
            ServerHelper.appUserUpdate(UIImagePNGRepresentation(self.iconImage!), nickname: self.nicknameTextField.text!, isMan: self.isMen!) { [weak self] (ret, error) -> Void in
                self?.saveButton.enabled = true
                if let error = error {
                    println(error)
                    return
                }
                if let weakSelf = self {
                    if ret!.success {
                        if weakSelf.mode == .newUser {
                            weakSelf.performSegueWithIdentifier("userToShow", sender: nil)
                        }
                        else {
                            weakSelf.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                    else {
                        UIAlertView.showMessage(ret!.errorMessage!)
                    }
                }
            }
        }
        
        if mode == .updateUser {
            ServerHelper.appUserGet(UserInfo.shared.id, completionHandler: { [weak self] (ret, error) -> Void in
                if let error = error {
                    println(error)
                    return
                }
                if let weakSelf = self {
                    if ret!.success {
                        weakSelf.iconImageView.imageWebUrl = ret!.data!.iconUrl!
                        weakSelf.isMen = ret!.data!.isMan!
                        weakSelf.nicknameTextField.text = ret!.data!.nickname!
                    }
                    else {
                        UIAlertView.showMessage(ret!.errorMessage!)
                    }
                }
            });
        }
    }
    
}
