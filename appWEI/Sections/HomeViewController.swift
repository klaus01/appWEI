//
//  HomeViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/26.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = self.navigationController {
            navigationController.navigationBarHidden = true
        }
    }

}
