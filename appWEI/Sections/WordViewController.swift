//
//  WordViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/21.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playSoundButton: UIButton!
    
    var word: WordModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textContainerInset = UIEdgeInsetsZero;
        
        imageView.imageWebUrl = word.pictureUrl
        numberLabel.text = word.number
        textView.text = word.description
        playSoundButton.hidden = word.audioUrl == nil
    }

    override func viewWillDisappear(animated: Bool) {
        playSoundButton.stopPlayWordSound()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func playSoundAction(sender: UIButton) {
        if let url = word.audioUrl {
            playSoundButton.playWordSoundUrl(url)
        }
    }
    
    @IBAction func shareItemAction(sender: UIButton) {
        UIActionSheet(title: nil, cancelButtonTitle: "下次再分享", destructiveButtonTitle: nil, otherButtonTitles: "分享到Facebook", "分享到Instagram", "分享到微信")
            .clicked({ (buttonAtIndex) -> () in
                // TODO 分享
            })
            .showInView(self.view)
    }
    
}
