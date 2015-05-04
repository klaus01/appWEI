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
            sender.playWordSoundUrl(url)
        }
    }
}
