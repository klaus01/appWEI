//
//  WordViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/21.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import AVFoundation

class WordViewController: UIViewController {
    
    private var audioPlayer: AVAudioPlayer?
    
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
        audioPlayer?.stop()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func playSoundAction(sender: AnyObject) {
        if let url = word.audioUrl {
            let fileName = url.lastPathComponent
            let filePath = getCachesDirectory() + "/" + fileName
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                self.playAmrFile(filePath)
            }
            else {
                download(Method.GET, url, { (temporaryURL, res) -> (NSURL) in
                    return NSURL(string: "file://" + filePath)!
                }).response { [weak self] (request, response, dd, error) in
                    // 404 没有error，而且文件还被保存了
                    if response?.statusCode == 404 {
                        println(response)
                        NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
                        return
                    }
                    // errorCode 516: 下载后保存的目标文件已经存在(同一文件下载多次时出现)
                    if error != nil && error!.code != 516 {
                        println(error)
                        return
                    }
                    if let weakSelf = self {
                        self!.playAmrFile(filePath)
                    }
                }
            }
        }
    }
    
    private func playAmrFile(amrFilePath: String) {
        let wavFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("amrtowav.wav")
        if VoiceConverter.amrToWav(amrFilePath, wavSavePath: wavFilePath) > 0 {
            audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: wavFilePath), error: nil)
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        }
    }
}
