//
//  FriendsViewController.swift
//  appWEI
//
//  Created by kelei on 15/3/27.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    private var friends = [FriendModel]()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = self.navigationController {
            navigationController.navigationBarHidden = false
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let i = ((collectionView.bounds.width - 300) / 3) / 2
        return UIEdgeInsets(top: i, left: i, bottom: i, right: i)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14//friends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! FriendCollectionViewCell
        cell.iconImage = UIImage(named: "Men2")
        cell.nickname = "柯"
        cell.messageCount = 4
        return cell;
    }


    // MARK: - UICollectionViewDelegate
}