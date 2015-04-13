//
//  CE_UIScrollView.swift
//  appWEI
//
//  Created by kelei on 15/4/11.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {
    
    private var ce: UIScrollView_Delegate {
        struct Static {
            static var AssociationKey: UInt8 = 0
        }
        if let obj = objc_getAssociatedObject(self, &Static.AssociationKey) as? UIScrollView_Delegate {
            return obj
        }
        if let delegate = self.delegate {
            if delegate is UIScrollView_Delegate {
                return delegate as! UIScrollView_Delegate
            }
        }
        let delegate = UIScrollView_Delegate()
        self.delegate = delegate
        objc_setAssociatedObject(self, &Static.AssociationKey, delegate, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        return delegate
    }
    
    public func ce_DidScroll(handle: (scrollView: UIScrollView) -> Void) -> UIScrollView {
        ce.DidScroll = handle
        return self
    }
    public func ce_DidEndDragging(handle: (scrollView: UIScrollView, decelerate: Bool) -> Void) -> UIScrollView {
        ce.DidEndDragging = handle
        return self
    }
    
}


class UIScrollView_Delegate: NSObject, UIScrollViewDelegate {
    
    var DidScroll: ((UIScrollView) -> Void)?
    var DidZoom: ((UIScrollView) -> Void)?
    var WillBeginDragging: ((UIScrollView) -> Void)?
    var WillEndDragging: ((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void)?
    var DidEndDragging: ((UIScrollView, Bool) -> Void)?
    var WillBeginDecelerating: ((UIScrollView) -> Void)?
    var DidEndDecelerating: ((UIScrollView) -> Void)?
    var DidEndScrollingAnimation: ((UIScrollView) -> Void)?
    var viewForZoomingInScrollView: ((UIScrollView) -> UIView?)?
    var WillBeginZooming: ((UIScrollView, UIView) -> Void)?
    var DidEndZooming: ((UIScrollView, UIView, CGFloat) -> Void)?
    var ShouldScrollToTop: ((UIScrollView) -> Bool)?
    var DidScrollToTop: ((UIScrollView) -> Void)?
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        
        let funcDic1: [Selector : Any?] = [
            "scrollViewDidScroll:" : DidScroll,
            "scrollViewDidZoom:" : DidZoom,
            "scrollViewWillBeginDragging:" : WillBeginDragging,
            "scrollViewWillEndDragging:withVelocity:targetContentOffset:" : WillEndDragging,
            "scrollViewDidEndDragging:willDecelerate:" : DidEndDragging,
            "scrollViewWillBeginDecelerating:" : WillBeginDecelerating,
            "scrollViewDidEndDecelerating:" : DidEndDecelerating,
        ]
        if let f = funcDic1[aSelector] {
            return f != nil
        }
        
        let funcDic2: [Selector : Any?] = [
            "scrollViewWillBeginZooming:withView:" : WillBeginZooming,
            "scrollViewDidEndZooming:withView:atScale:" : DidEndZooming,
            "scrollViewShouldScrollToTop:" : ShouldScrollToTop,
            "scrollViewDidScrollToTop:" : DidScrollToTop,
            "viewForZoomingInScrollView:" : viewForZoomingInScrollView,
        ]
        if let f = funcDic2[aSelector] {
            return f != nil
        }
        println(aSelector)
        return super.respondsToSelector(aSelector)
    }
    
    // MARK: - UIScrollViewDelegate
    
    @objc func scrollViewDidScroll(scrollView: UIScrollView) {
        DidScroll!(scrollView)
    }
    @objc func scrollViewDidZoom(scrollView: UIScrollView) {
        DidZoom!(scrollView)
    }
    @objc func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        WillBeginDragging!(scrollView)
    }
    @objc func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        WillEndDragging!(scrollView, velocity, targetContentOffset)
    }
}