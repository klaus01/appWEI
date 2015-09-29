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
    private var viewFrameY: CGFloat = 0
    private let hintText = "亲，科普一下这字虾米意思吧"
    
    var wordImage: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = wordImage
        setupDescriptionTextView()
        setupRecorder()
        setupRecordButton()
        setupPlayButton()
        
        ce_addObserverForName(UIKeyboardWillShowNotification, handle: { [weak self] (notification) -> Void in
            if self!.viewFrameY == 0 {
                self!.viewFrameY = self!.view.frame.origin.y
            }
            let info = notification.userInfo!
            let duation = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let options = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue
            UIView.animateWithDuration(duation, delay: 0, options: UIViewAnimationOptions(options), animations: { () -> Void in
                var frame = self!.view.frame
                frame.origin.y = self!.viewFrameY - CGRectGetMaxY(self!.imageView.frame)
                self!.view.frame = frame
            }, completion: nil)
        })
        ce_addObserverForName(UIKeyboardWillHideNotification, handle: { [weak self] (notification) -> Void in
            let info = notification.userInfo!
            let duation = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let options = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue
            UIView.animateWithDuration(duation, delay: 0, options: UIViewAnimationOptions(options), animations: { () -> Void in
                var frame = self!.view.frame
                frame.origin.y = self!.viewFrameY
                self!.view.frame = frame
            }, completion: nil)
        })
    }

    private func setupDescriptionTextView() {
        descriptionTextView.text = hintText;
        descriptionTextView
        .ce_ShouldBeginEditing { [weak self] (textView) -> Bool in
            if textView.text == self!.hintText {
                textView.text = ""
            }
            return true
        }
        .ce_ShouldChangeTextInRange { (textView, range, text) -> Bool in
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
        .ce_DidEndEditing { [weak self] (textView) -> Void in
            if textView.text.length <= 0 {
                textView.text = self!.hintText
            }
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
            self!.countdown = 5 * 10 + 1
            self!.progressView.progress = 0
            self!.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self!, selector: "onCountdownTimer", userInfo: nil, repeats: true)
            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                self!.onCountdownTimer()
            })
        })
        recordButton.__on(UIControlEvents.TouchUpInside, action: { [weak self] (control) -> () in
            if self!.recorder.recording {
                self!.recorder.stop()
                self!.countdownTimer.invalidate()
                self!.countdownTimer = nil
            }
        })
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
            
            self!.progressView.progress = 0
            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                UIView.animateWithDuration(self!.audioPlay.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self!.progressView.setProgress(1, animated: true)
                }, completion: nil)
            })
        }
    }
    
    func onCountdownTimer() {
        countdown--
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.progressView.setProgress(self.progressView.progress + 1.0 / 50.0, animated: true)
        }, completion: nil)
        if countdown <= 0 {
            recorder.stop()
            countdownTimer.invalidate()
            countdownTimer = nil
        }
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        if descriptionTextView.text == hintText {
            UIAlertView.showMessage("请输入字的解释！", cancelButtonTitle: "好")
            return
        }
        
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
                    // TODO 造了字需要弹出分享菜单，是在哪个界面弹呢？
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
