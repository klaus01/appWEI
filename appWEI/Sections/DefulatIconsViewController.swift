//
//  DefulatIconsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/26.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class DefulatIconsViewController: UIViewController {
    
    // MARK: - Private func
    
    private func resultImageAndSex(image: UIImage) {
        self.navigationController?.popViewControllerAnimated(true)
        if let vc: AnyObject = self.navigationController?.viewControllers.last {
            if vc is UserInfoViewController {
                let vc = vc as! UserInfoViewController
                vc.iconImage = image
                vc.isMen = sexSegmentedControl.selectedSegmentIndex == 0
            }
        }
    }
    
    private func setImage(headName: String) {
        image1.image = UIImage(named: headName + "1")
        image2.image = UIImage(named: headName + "2")
        image3.image = UIImage(named: headName + "3")
        image4.image = UIImage(named: headName + "4")
        image5.image = UIImage(named: headName + "5")
        image6.image = UIImage(named: headName + "6")
        image7.image = UIImage(named: headName + "7")
        image8.image = UIImage(named: headName + "8")
        image9.image = UIImage(named: headName + "9")
    }
    
    // MARK: - IB
    
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    @IBOutlet weak var image9: UIImageView!
    
    @IBAction func sexValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setImage("Men")
        }
        else {
            setImage("Women")
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sexSegmentedControl.selectedSegmentIndex = 0
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let obj = touches.first {
            if let touch = obj as? UITouch {
                if (touch.view is UIImageView) {
                    let image = (touch.view as! UIImageView).image!
                    resultImageAndSex(image)
                }
                else {
                    return
                }
            }
        }
    }
    
}
