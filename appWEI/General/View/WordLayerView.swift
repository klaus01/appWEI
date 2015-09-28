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
    
    var fontColor: UIColor = UIColor.blackColor() {
        didSet {
            wordView.fontColor = fontColor
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
    
    // MAKE: - Touchs
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if touch.tapCount == 1 {
                if mode == .MoveZoomRotation {
                    touchBeginPoint = touch.locationInView(self)
                }
                else {
                    wordView.addEraserLineWithBeginPoint(touch.locationInView(wordView))
                }
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if touch.tapCount == 1 {
                if mode == .MoveZoomRotation {
                    let newPoint = touch.locationInView(self)
                    var center = wordView.center
                    center.x += newPoint.x - touchBeginPoint.x
                    center.y += newPoint.y - touchBeginPoint.y
                    wordView.center = center
                    touchBeginPoint = newPoint
                }
                else {
                    wordView.addEraserPoint(touch.locationInView(wordView))
                }
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        if let touch = touches.first as? UITouch {
            doChanged()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if let touch = touches.first as? UITouch {
            doChanged()
        }
    }
    
    // MARK: - Private
    
    private class WordView: UIView {
        private var eraserPaths: [(CGFloat, [CGPoint])] = [(CGFloat, [CGPoint])]()
        private var word: String!
        private var font: UIFont!
        private var fontColor: UIColor! {
            didSet {
                setNeedsDisplay()
            }
        }
        init(word: String, font: UIFont, fontColor: UIColor) {
            self.word = word
            self.font = font
            self.fontColor = fontColor
            super.init(frame: CGRectZero)
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func drawRect(rect: CGRect) {
            super.drawRect(rect)
            
            // 居中显示 字
            let str = NSString(string: word)
            let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor]
            let strSize = str.sizeWithAttributes(attrs)
            let strRect = CGRectMake((rect.size.width - strSize.width) / 2, (rect.size.height - strSize.height) / 2, strSize.width, strSize.height)
            str.drawInRect(strRect, withAttributes: attrs)
            
            // 橡皮擦 线条
            if eraserPaths.count > 0 {
                let context=UIGraphicsGetCurrentContext()
                CGContextSetLineCap(context, kCGLineCapRound)
                CGContextSetLineJoin(context,kCGLineJoinRound)
                CGContextSetBlendMode(context, kCGBlendModeClear)
                for (scale, points) in eraserPaths {
                    var moved = false
                    for point in points {
                        if !moved {
                            CGContextMoveToPoint(context, point.x, point.y)
                            moved = true
                        }
                        CGContextAddLineToPoint(context, point.x,point.y)
                    }
                    CGContextSetLineWidth(context, CGFloat(44) / scale)
                    CGContextStrokePath(context)
                }
            }
        }
        func addEraserLineWithBeginPoint(point: CGPoint) {
            eraserPaths.append(getScale(), [point])
            setNeedsDisplay()
        }
        func addEraserPoint(point: CGPoint) {
            var (scale, line) = eraserPaths.removeLast()
            line.append(point)
            eraserPaths += [(scale, line)]
            setNeedsDisplay()
        }
        private func getScale() -> CGFloat {
            let t = transform
            return sqrt(t.a * t.a + t.c * t.c)
        }
    }
    
    private var touchBeginPoint: CGPoint = CGPointZero
    private var wordView: WordView!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    
    private func setupWordView(#word: String, font: UIFont) {
        wordView = WordView(word: word, font: font, fontColor: fontColor)
        wordView.backgroundColor = UIColor.clearColor()
        wordView.frame = bounds
        wordView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(wordView)
    }
    
    private func setupPinchGesture() {
        pinchGesture = UIPinchGestureRecognizer() { [weak self] (gestureRecognizer) -> () in
            if let gestureRecognizer = gestureRecognizer as? UIPinchGestureRecognizer {
                if gestureRecognizer.state == .Began {
                    let locationInView = gestureRecognizer.locationInView(self!.wordView)
                    let locationInSuperview = gestureRecognizer.locationInView(self!)
                    self!.wordView.layer.anchorPoint = CGPointMake(locationInView.x / self!.wordView.bounds.size.width, locationInView.y / self!.wordView.bounds.size.height)
                    self!.wordView.center = locationInSuperview
                }
                else if gestureRecognizer.state == .Changed {
                    let scale = gestureRecognizer.scale
                    self!.wordView.transform = CGAffineTransformScale(self!.wordView.transform, scale, scale)
                    gestureRecognizer.scale = 1
                }
                else if gestureRecognizer.state == .Ended || gestureRecognizer.state == .Cancelled {
                    self!.doChanged()
                }
            }
        }
        pinchGesture.ce_ShouldRecognizeSimultaneouslyWithGestureRecognizer { (gestureRecognizer, otherGestureRecognizer) -> Bool in
            return true
        }
    }
    
    private func setupRotationGesture() {
        rotationGesture = UIRotationGestureRecognizer() { [weak self] (gestureRecognizer) -> () in
            if let gestureRecognizer = gestureRecognizer as? UIRotationGestureRecognizer {
                if gestureRecognizer.state == .Began {
                    let locationInView = gestureRecognizer.locationInView(self!.wordView)
                    let locationInSuperview = gestureRecognizer.locationInView(self!)
                    self!.wordView.layer.anchorPoint = CGPointMake(locationInView.x / self!.wordView.bounds.size.width, locationInView.y / self!.wordView.bounds.size.height)
                    self!.wordView.center = locationInSuperview
                }
                else if gestureRecognizer.state == .Changed {
                    self!.wordView.transform = CGAffineTransformRotate(self!.wordView.transform, gestureRecognizer.rotation)
                    gestureRecognizer.rotation = 0
                }
                else if gestureRecognizer.state == .Ended || gestureRecognizer.state == .Cancelled {
                    self!.doChanged()
                }
            }
        }
        rotationGesture.ce_ShouldRecognizeSimultaneouslyWithGestureRecognizer { (gestureRecognizer, otherGestureRecognizer) -> Bool in
            return true
        }
    }
    
    private func doChanged() {
        onChanged?(self)
    }
    
}
