//
//  SlideshowViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/22.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class SlideshowViewController: UIViewController {

    @IBAction func enterHomeClick(sender: AnyObject) {
        ServerHelper.appUserEnterHome { (ret, error) -> Void in
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = self.navigationController {
            navigationController.navigationBarHidden = true
        }
    }

}
