//
//  WordImageCreateViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class WordImageCreateViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var addLayerButton: UIButton!
    @IBOutlet weak var clearLayerButton: UIButton!
    @IBOutlet weak var layersCollectionView: UICollectionView!
    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddLayerButton()
        setupClearLayerButton()
        setupLayersCollectionView()
        setupModeSegmentedControl()
        refreshRextButtonEnabled()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is WordSoundCreateViewController {
            (segue.destinationViewController as! WordSoundCreateViewController).wordImage = wordView.captureView()
        }
    }

    private func setupAddLayerButton() {
        addLayerButton.clicked() { [weak self] (button) -> () in
            self!.showInputWordAlertView()
        }
    }
    
    private func setupClearLayerButton() {
        clearLayerButton.clicked() { [weak self] (button) -> () in
            while self!.wordLayerViews.count > 0 {
                let wordLayerView = self!.wordLayerViews.removeLast()
                wordLayerView.removeFromSuperview()
            }
            self!.layersCollectionView.reloadData()
            self!.refreshRextButtonEnabled()
        }
    }
    
    private func setupLayersCollectionView() {
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        layersCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "MYCELL")
        layersCollectionView
        .ce_LayoutSizeForItemAtIndexPath { (collectionView, collectionViewLayout, indexPath) -> CGSize in
            return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.width)
        }
        .ce_LayoutMinimumLineSpacingForSectionAtIndex { (collectionView, collectionViewLayout, section) -> CGFloat in
            return CGFloat(8)
        }
        .ce_LayoutInsetForSectionAtIndex { (collectionView, collectionViewLayout, section) -> UIEdgeInsets in
            return UIEdgeInsetsZero
        }
        .ce_NumberOfItemsInSection { [weak self] (collectionView, section) -> Int in
            return self!.wordLayerViews.count
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
            if cell.selectedBackgroundView == nil {
                cell.selectedBackgroundView = UIView()
            }
            cell.selectedBackgroundView.backgroundColor = UIColor.blueColor()
            
            let wordLayer = self!.wordLayerViews[indexPath.item]
            cell.imageView.image = wordLayer.captureView()
            
            return cell
        }
        .ce_DidSelectItemAtIndexPath { [weak self] (collectionView, indexPath) -> Void in
            self!.wordView.bringSubviewToFront(self!.wordLayerViews[indexPath.item])
        }
    }
    
    private func setupModeSegmentedControl() {
        modeSegmentedControl.selectedIndexChange() { [weak self] (Int) -> () in
            let mode = self!.currectEditMode
            for wordLayerView in self!.wordLayerViews {
                wordLayerView.mode = mode
            }
        }
    }
    
    private var wordLayerViews: [WordLayerView] = [WordLayerView]()
    private var wordFont: UIFont!
    private var currectEditMode: WordLayerMode {
        return modeSegmentedControl.selectedSegmentIndex == 0 ? .MoveZoomRotation : .Eraser
    }
    
    private func createWordFontWithSize(size: CGSize) -> UIFont {
        let str = NSString(string: "测")
        var fontSize = 50.0
        var frame = CGRectZero
        var prevFont: UIFont!
        var font: UIFont!
        do {
            prevFont = font
            font = UIFont.systemFontOfSize(CGFloat(fontSize))
            frame = str.boundingRectWithSize(CGSizeZero, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            fontSize *= 1.25
        } while frame.size.width < size.width && frame.size.height < size.height
        return prevFont
    }
    
    private func addWordLayer(word: String) {
        if wordFont == nil {
            wordFont = createWordFontWithSize(wordView.bounds.size)
        }
        let wordLayer = WordLayerView(word: word, font: wordFont)
        wordLayer.frame = wordView.bounds
        wordLayer.backgroundColor = UIColor.clearColor()
        wordLayer.mode = currectEditMode
        wordLayer.onChanged = { [weak self] (wordLayer) -> () in
            if let index = self!.wordLayerViews.indexOf(wordLayer) {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                self!.layersCollectionView.reloadItemsAtIndexPaths([indexPath])
                self!.layersCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            }
        }
        
        wordView.addSubview(wordLayer)
        wordLayerViews.append(wordLayer)
        let indexPath = NSIndexPath(forItem: wordLayerViews.count - 1, inSection: 0)
        layersCollectionView.insertItemsAtIndexPaths([indexPath])
        layersCollectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.Bottom)
        
        refreshRextButtonEnabled()
    }
    
    private func showInputWordAlertView(defaultWord: String? = nil) {
        let alertView = UIAlertView(title: "添加图层", message: "输入一个字", cancelButtonTitle: "取消", otherButtonTitles: "添加")
        alertView.alertViewStyle = .PlainTextInput
        if let textField = alertView.textFieldAtIndex(0) {
            textField.placeholder = "输入一个字"
            textField.text = defaultWord
            textField.textAlignment = NSTextAlignment.Center
            alertView.clicked() { [weak self] (buttonAtIndex) -> () in
                if (buttonAtIndex > 0) {
                    if textField.text.length > 1 {
                        self!.showInputWordAlertView(defaultWord: textField.text)
                    }
                    else {
                        self!.addWordLayer(textField.text)
                    }
                }
            }
            alertView.show()
        }
    }
    
    private func refreshRextButtonEnabled() {
        nextButton.enabled = wordLayerViews.count > 0
    }
    
}
