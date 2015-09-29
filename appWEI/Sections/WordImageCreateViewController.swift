//
//  WordImageCreateViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class WordImageCreateViewController: UIViewController {
    
    @IBOutlet weak var fontTextField: UITextField!
    @IBOutlet weak var clearLayerButton: UIButton!
    @IBOutlet weak var layersCollectionView: UICollectionView!
    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var wordBGView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontFamilies = UIFont.familyNames() as! [String]
        setupFontTextField()
        setupClearLayerButton()
        setupLayersCollectionView()
        setupModeSegmentedControl()
        refreshButtonEnabled()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is WordSoundCreateViewController {
            activeWordLayer(-1)
            wordBGView.hidden = true
            (segue.destinationViewController as! WordSoundCreateViewController).wordImage = wordView.captureView()
            wordBGView.hidden = false
            layersCollectionView.reloadData()
        }
    }
    
    private func setupFontTextField() {
        self.fontTextField.inputView = UIPickerView()
        .ce_numberOfComponentsIn({ (pickerView) -> Int in
            return 1
        })
        .ce_numberOfRowsInComponent { [weak self] (pickerView, component) -> Int in
            return self!.fontFamilies.count
        }
        .ce_viewForRow { [weak self] (pickerView, row, component, view) -> UIView in
            let fontName = self!.fontFamilies[row]
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = fontName
            pickerLabel.font = UIFont(name: fontName, size: 17)
            pickerLabel.textAlignment = NSTextAlignment.Center
            return pickerLabel
        }
        .ce_didSelectRow { [weak self] (pickerView, row, component) -> Void in
            let fontName = self!.fontFamilies[row]
            self!.fontTextField.text = "字体：\(fontName)"
            self!.fontTextField.font = UIFont(name: fontName, size: 14)
        }
        
        let completeButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Bordered) { [weak self] UIBarButtonItem -> () in
            self!.fontTextField.resignFirstResponder()
        }
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 44))
        toolbar.items = [flexibleSpace, completeButton]
        self.fontTextField.inputAccessoryView = toolbar
    }
    
    private func setupClearLayerButton() {
        clearLayerButton.clicked() { [weak self] (button) -> () in
            UIAlertView.yesOrNo("确定要删除所有内容？", yesButtonTitle: "确定", noButtonTitle: "取消", didDismiss: { [weak self] isYes -> Void in
                if !isYes {
                    return
                }
                while self!.wordLayerViews.count > 0 {
                    let wordLayerView = self!.wordLayerViews.removeLast()
                    wordLayerView.removeFromSuperview()
                }
                self!.layersCollectionView.reloadData()
                self!.refreshButtonEnabled()
            })
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
            return self!.wordLayerViews.count + 1
        }
        .ce_CellForItemAtIndexPath { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MYCELL", forIndexPath: indexPath) as! ImageCollectionViewCell
            if indexPath.item < self!.wordLayerViews.count {
                let wordLayer = self!.wordLayerViews[indexPath.item]
                cell.imageView.image = wordLayer.captureView()
            }
            else {
                cell.imageView.image = UIImage(named: "add_friend")
            }
            
            return cell
        }
        .ce_DidSelectItemAtIndexPath { [weak self] (collectionView, indexPath) -> Void in
            if indexPath.item < self!.wordLayerViews.count {
                self!.activeWordLayer(indexPath.item)
                collectionView.reloadData()
            }
            else {
                self!.showInputWordAlertView()
            }
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
    private var fontFamilies: [String]!
    private var currectEditMode: WordLayerMode {
        return modeSegmentedControl.selectedSegmentIndex == 0 ? .MoveZoomRotation : .Eraser
    }
    
    private func createWordFontWithSize(fontName: String, size: CGSize) -> UIFont {
        let str = NSString(string: "测")
        var fontSize = 50.0
        var frame = CGRectZero
        var prevFont: UIFont!
        var font: UIFont!
        do {
            prevFont = font
            font = UIFont(name: fontName, size: CGFloat(fontSize))
            frame = str.boundingRectWithSize(CGSizeZero, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            fontSize *= 1.25
        } while frame.size.width < size.width && frame.size.height < size.height
        return prevFont
    }
    
    private func addWordLayer(word: String) {
        let wordFont = createWordFontWithSize(self.fontTextField.font.familyName, size: wordView.bounds.size)
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
        activeWordLayer(indexPath.item)
        layersCollectionView.reloadData()
        
        refreshButtonEnabled()
    }
    
    private func activeWordLayer(index: Int) {
        wordLayerViews.each { (i, wordLayer) -> () in
            if i == index {
                wordLayer.fontColor = UIColor.redColor()
                self.wordView.bringSubviewToFront(wordLayer)
            }
            else {
                wordLayer.fontColor = UIColor.blackColor()
            }
        }
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
    
    private func refreshButtonEnabled() {
        modeSegmentedControl.hidden = wordLayerViews.count <= 0
        clearLayerButton.hidden = wordLayerViews.count <= 0
        nextButton.enabled = wordLayerViews.count > 0
    }
    
}
