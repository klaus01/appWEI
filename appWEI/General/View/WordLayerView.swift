//
//  WordLayerView.swift
//  appWEI
//
//  Created by kelei on 15/5/23.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

/**
造字图层的操作模式

- Eraser:           橡皮擦
- MoveZoomRotation: 移动、缩放、旋转
*/
enum WordLayerMode {
    case Eraser
    case MoveZoomRotation
}

/**
  造字用的一个图层
*/
class WordLayerView: UIView {
    
    /// 当前编辑模式。默认：.MoveZoomRotation
    var mode: WordLayerMode = .MoveZoomRotation {
        didSet {
            pinchGesture.enabled = mode == .MoveZoomRotation
            rotationGesture.enabled = mode == .MoveZoomRotation
        }
    }
    
    /// 图层内容已改变事件
    var onChanged: ((WordLayerView) -> ())?
    
    /**
    实例化方法
    
    :param: word 要显示的字
    :param: font 显示的字体
    
    :returns: 实例
    */
    init(word: String, font: UIFont) {
        super.init(frame: CGRectZero)
        setupWordView(word: word, font: font)
        setupPinchGesture()
        setupRotationGesture()
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(rotationGesture)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private
    
    private class WordView: UIView {
        private var word: String!
        private var font: UIFont!
        init(word: String, font: UIFont) {
            self.word = word
            self.font = font
            super.init(frame: CGRectZero)
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func drawRect(rect: CGRect) {
            super.drawRect(rect)
            
            let str = NSString(string: word)
            let attrs = [NSFontAttributeName: font]
            let strSize = str.sizeWithAttributes(attrs)
            let strRect = CGRectMake((rect.size.width - strSize.width) / 2, (rect.size.height - strSize.height) / 2, strSize.width, strSize.height)
            str.drawInRect(strRect, withAttributes: attrs)
        }
    }
    
    private var wordView: WordView!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    
    private func setupWordView(#word: String, font: UIFont) {
        wordView = WordView(word: word, font: font)
        wordView.backgroundColor = UIColor.clearColor()
        wordView.frame = bounds
        wordView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(wordView)
    }
    
    private func setupPinchGesture() {
        pinchGesture = UIPinchGestureRecognizer() { [weak self] (gestureRecognizer) -> () in
            if gestureRecognizer.state == .Changed {
                let scale = self!.pinchGesture.scale
                self!.wordView.transform = CGAffineTransformScale(self!.wordView.transform, scale, scale)
                self!.pinchGesture.scale = 1
            }
            else if gestureRecognizer.state == .Ended || gestureRecognizer.state == .Cancelled {
                self!.doChanged()
            }
        }
    }
    
    private func setupRotationGesture() {
        rotationGesture = UIRotationGestureRecognizer() { [weak self] (gestureRecognizer) -> () in
            if gestureRecognizer.state == .Changed {
                self!.wordView.transform = CGAffineTransformRotate(self!.wordView.transform, self!.rotationGesture.rotation)
                self!.rotationGesture.rotation = 0
            }
            else if gestureRecognizer.state == .Ended || gestureRecognizer.state == .Cancelled {
                self!.doChanged()
            }
        }
    }
    
    private func doChanged() {
        if let f = onChanged {
            f(self)
        }
    }
    
}
