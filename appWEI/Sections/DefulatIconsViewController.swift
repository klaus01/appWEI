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
                vc.isMen = femaleLineView.hidden
            }
        }
    }
    
    private func setImage(headName: String) {
        let images = [image1, image2, image3, image4, image5, image6, image7, image8, image9]
        for (var i = 0; i < images.count; i++) {
            images[i].image = UIImage(named: "\(headName)\(i + 1)")
        }
    }
    
    // MARK: - IB
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleLineView: UIView!
    @IBOutlet weak var femaleLineView: UIView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    @IBOutlet weak var image9: UIImageView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        femaleLineView.hidden = true
        maleButton.clicked { [unowned self] btn -> () in
            self.setImage("Men")
            self.maleLineView.hidden = false
            self.femaleLineView.hidden = true
        }
        femaleButton.clicked { [unowned self] btn -> () in
            self.setImage("Women")
            self.maleLineView.hidden = true
            self.femaleLineView.hidden = false
        }
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
