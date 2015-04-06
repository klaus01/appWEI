//
//  SendMessageViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - IB
    
    @IBOutlet weak var wordGroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func closeClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        friendsCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        // Do any additional setup after loading the view.
    }

    // MARK: - UICollectionViewDataSource
        
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
        
}
