//
//  UICollectionView+CE.swift
//  appWEI
//
//  Created by kelei on 15/4/8.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import UIKit


private var ceAssociationKey: UInt8 = 0


extension UICollectionView {
    
    private var ce: UICollectionView_Delegate {
        if let obj = objc_getAssociatedObject(self, &ceAssociationKey) as? UICollectionView_Delegate {
            return obj
        }
        if let delegate = self.delegate {
            if delegate is UICollectionView_Delegate {
                return delegate as! UICollectionView_Delegate
            }
        }
        let delegate = UICollectionView_Delegate()
        self.delegate = delegate
        self.dataSource = delegate
        objc_setAssociatedObject(self, &ceAssociationKey, delegate, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        return delegate
    }
    
    public func ce_NumberOfItemsInSection(handle: (collectionView: UICollectionView, section: Int) -> Int) -> UICollectionView {
        ce.NumberOfItemsInSection = handle
        return self
    }
    
    public func ce_CellForItemAtIndexPath(handle: (collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell) -> UICollectionView {
        ce.CellForItemAtIndexPath = handle
        return self
    }
    
    public func ce_NumberOfSectionsInCollectionView(handle: (collectionView: UICollectionView) -> Int) -> UICollectionView {
        ce.NumberOfSectionsInCollectionView = handle
        return self
    }
    
    public func ce_ViewForSupplementaryElementOfKind(handle: (collectionView: UICollectionView, kind: String, indexPath: NSIndexPath) -> UICollectionReusableView) -> UICollectionView {
        ce.ViewForSupplementaryElementOfKind = handle
        return self
    }
    
}


private class UICollectionView_Delegate: UIScrollView_Delegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var NumberOfItemsInSection: ((UICollectionView, Int) -> Int)?
    var CellForItemAtIndexPath: ((UICollectionView, NSIndexPath) -> UICollectionViewCell)?
    var NumberOfSectionsInCollectionView: ((UICollectionView) -> Int)?
    var ViewForSupplementaryElementOfKind: ((UICollectionView, String, NSIndexPath) -> UICollectionReusableView)?
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        let funcDic: [Selector : Any?] = [
            "collectionView:numberOfItemsInSection:" : NumberOfItemsInSection,
            "collectionView:cellForItemAtIndexPath:" : CellForItemAtIndexPath,
            "numberOfSectionsInCollectionView:" : NumberOfSectionsInCollectionView,
            "collectionView:viewForSupplementaryElementOfKind:atIndexPath:" : ViewForSupplementaryElementOfKind,
        ]
        if let f = funcDic[aSelector] {
            return f != nil
        }
        
        return super.respondsToSelector(aSelector)
    }
    
    // MARK: - UICollectionViewDataSource
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NumberOfItemsInSection!(collectionView, section)
    }
    
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return CellForItemAtIndexPath!(collectionView, indexPath)
    }
    
    @objc func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return NumberOfSectionsInCollectionView!(collectionView)
    }
    
    @objc func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return ViewForSupplementaryElementOfKind!(collectionView, kind, indexPath)
    }
}