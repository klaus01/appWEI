//
//  WordSoundCreateViewController.swift
//  appWEI
//
//  Created by kelei on 15/4/6.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import UIKit
import AVFoundation

class WordSoundCreateViewController: UIViewController, AVAudioRecorderDelegate {

    private var recorder: AVAudioRecorder!
    private var audioPlay: AVAudioPlayer!
    private var countdownTimer: NSTimer!
    private var countdown: Int = 0
    
    var wordImage: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = wordImage
        setupDescriptionTextView()
        setupRecorder()
        setupRecordButton()
        setupAudioPlay()
        setupPlayButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupDescriptionTextView() {
        descriptionTextView.ce_ShouldChangeTextInRange { (textView, range, text) -> Bool in
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    }
    
    private func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        session.setActive(true, error: nil)
        
        let settings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 8000
        ]
        recorder = AVAudioRecorder(URL: NSURL(string: NSTemporaryDirectory().stringByAppendingPathComponent("sound.wav")), settings: settings, error: nil)
        recorder.delegate = self
        recorder.prepareToRecord()
    }
    
    private func setupRecordButton() {
        recordButton.__on(UIControlEvents.TouchDown, action: { [weak self] (control) -> () in
            let session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            session.setActive(true, error: nil)
            self!.recorder.record()
            self!.countdown = 5
            self!.countdownLabel.text = self!.countdown.description
            self!.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self!, selector: "onCountdownTimer", userInfo: nil, repeats: true)
        })
        recordButton.__on(UIControlEvents.TouchUpInside, action: { [weak self] (control) -> () in
            if self!.recorder.recording {
                self!.recorder.stop()
                self!.countdownLabel.text = ""
                self!.countdownTimer.invalidate()
                self!.countdownTimer = nil
            }
        })
    }
    
    private func setupAudioPlay() {
    }
    
    private func setupPlayButton() {
        playButton.enabled = false
        playButton.clicked() { [weak self] (button) -> () in
            let session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
            session.setActive(true, error: nil)
            self!.audioPlay = AVAudioPlayer(contentsOfURL: self!.recorder.url, error: nil)
            self!.audioPlay.prepareToPlay()
            self!.audioPlay.play()
        }
    }
    
    func onCountdownTimer() {
        countdown--
        countdownLabel.text = countdown.description
        if countdown <= 0 {
            recorder.stop()
            countdownLabel.text = ""
            countdownTimer.invalidate()
            countdownTimer = nil
        }
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        var audioData: NSData?
        let imageData: NSData = UIImagePNGRepresentation(wordImage)
        
        if playButton.enabled {
            let amrFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("wavtoamr.amr")
            if VoiceConverter.wavToAmr(recorder.url.absoluteString, amrSavePath: amrFilePath) > 0 {
                audioData = NSData(contentsOfFile: amrFilePath)
            }
            else {
                UIAlertView.showMessage("转换音频文件失败！", cancelButtonTitle: "哦")
                return
            }
        }
        ServerHelper.wordNew(descriptionTextView.text, pictureFile: imageData, audioFile: audioData) { [weak self] (ret, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            if let weakSelf = self {
                if ret!.success {
                    NSNotificationCenter.defaultCenter().postNotificationName(kNotification_NewWord, object: ret!.data!.newWordID)
                }
                else {
                    UIAlertView.showMessage(ret!.errorMessage!)
                }
            }
            // 提示，发消息
        }
    }

    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        playButton.enabled = flag
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        recorder.deleteRecording()
    }
    
}
