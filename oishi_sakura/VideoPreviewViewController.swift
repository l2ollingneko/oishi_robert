//
//  VideoPreviewViewController.swift
//  oishi
//
//  Created by warinporn khantithamaporn on 8/29/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPreviewViewController: UIViewController {
    
    var avPlayer = AVPlayer()
    var avPlayerLayer = AVPlayerLayer()
    var videoView = UIView()
    
    var bottomBar = UIView()
    var playImageView = UIImageView()
    var playButton = UIButton()
    var closeButton = UIButton()
    var timeTrack = M13ProgressViewBorderedBar()
    
    var url: URL?
    var videoUrlString: String?
    var videoFilePath: String?
    var isCheckingPassed: Bool = false
    
    var duration: Float64 = 0
    
    var timer: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
        let barSize = CGSize.init(width: Adapter.rWidth, height: Adapter.calculatedHeightFromRatio(height: 202.0))
        self.bottomBar.frame = CGRect.init(x: 0.0, y: Adapter.rHeight - barSize.height, width: barSize.width, height: barSize.height)
        self.bottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.bottomBar.layer.zPosition = 1000
        
        self.playImageView.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 62.0), y: Adapter.calculatedWidthFromRatio(width: 33.0), width: Adapter.calculatedWidthFromRatio(width: 136.0), height: Adapter.calculatedWidthFromRatio(width: 136.0))
        self.playImageView.image = UIImage(named: "preview_video_play_button")
        self.playImageView.backgroundColor = UIColor.clear
        
        self.playButton.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 2.0), y: 0.0, width: Adapter.calculatedWidthFromRatio(width: 202.0), height: Adapter.calculatedWidthFromRatio(width: 202.0))
        self.playButton.backgroundColor = UIColor.clear
        /*
        self.playButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: 0.85)
        self.playButton.setTitle("Play Video", for: .normal)
        self.playButton.setTitleColor(UIColor.white, for: .normal)
         */
        self.playButton.addTarget(self, action: #selector(VideoPreviewViewController.checkVideo), for: .touchUpInside)
        
        self.closeButton.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 1000.0), y: Adapter.calculatedHeightFromRatio(height: 50.0), width: Adapter.calculatedWidthFromRatio(width: 193.0), height: Adapter.calculatedHeightFromRatio(height: 196.0))
        self.closeButton.setImage(UIImage(named: "tutorial_close_button"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(VideoPreviewViewController.closeDidTap), for: .touchUpInside)
        self.closeButton.isUserInteractionEnabled = true
        self.closeButton.layer.zPosition = 1000
        
        let progressBarSize = CGSize.init(width: Adapter.rWidth - Adapter.calculatedWidthFromRatio(width: 326.0), height: Adapter.calculatedHeightFromRatio(height: 40.0))
        self.timeTrack.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 264.0), y: Adapter.calculatedHeightFromRatio(height: (202.0 - 40.0) / 2.0), width: progressBarSize.width, height: progressBarSize.height)
        self.timeTrack.layer.cornerRadius = progressBarSize.height / 2.0
        self.timeTrack.clipsToBounds = true
        self.timeTrack.layer.borderColor = UIColor.white.cgColor
        self.timeTrack.layer.borderWidth = Adapter.calculatedWidthFromRatio(width: 8.0)
        self.timeTrack.primaryColor = UIColor.white
        self.timeTrack.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        self.bottomBar.addSubview(self.playImageView)
        self.bottomBar.addSubview(self.playButton)
        self.bottomBar.addSubview(self.timeTrack)
        
        self.videoView.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        self.videoView.backgroundColor = UIColor.black
        
        self.view.addSubview(self.videoView)
        self.videoView.addSubview(self.closeButton)
        self.videoView.addSubview(self.bottomBar)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoPreviewViewController.playerDidPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.avPlayer.replaceCurrentItem(with: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("fucking check video")
        self.checkVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkVideo() {
        // TODO: - check video exist in file
        if ((self.avPlayer.rate != 0) && (self.avPlayer.error == nil)) {
            self.avPlayer.pause()
        } else if (self.isCheckingPassed) {
            self.avPlayer.play()
        } else {
            if let url = self.url {
                self.playVideo(url: url)
            }
        }
    }
    
    func playVideo(url: URL) {
        self.avPlayerLayer.removeFromSuperlayer()
        
        self.avPlayer = AVPlayer(url: url)
        self.avPlayer.actionAtItemEnd = .none
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        self.avPlayerLayer.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.videoView.layer.addSublayer(self.avPlayerLayer)
        
        let item = avPlayer.currentItem
        self.duration = CMTimeGetSeconds((item?.asset.duration)!)
        
        self.avPlayer.seek(to: kCMTimeZero)
        
        print("duration: \(duration)")
        
        let interval = CMTimeMakeWithSeconds(0.1, 1000)
        self.timer = self.avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { time in
            self.timeTrack.setProgress(CGFloat(CGFloat(time.seconds) / CGFloat(self.duration)), animated: true)
        })
        
        self.avPlayer.play()
    }
    
    func playerDidPlayToEnd() {
        self.dismiss(animated: false, completion: nil)
        self.avPlayer.pause()
        //  1self.avPlayer.removeTimeObserver(self.timer!)
    }
    
    // MARK: - downloadvideocontrollerdelegate
    
    /*
    func finishedDownloadResources() {
        self.download?.dismissViewControllerAnimated(false, completion: nil)
        let splitedString = self.videoUrlString!.characters.split{$0 == "/"}.map(String.init)
        let fileName = splitedString[splitedString.count - 1]
        let videoFilePath = self.getVideoFilePath(fileName)
        self.isCheckingPassed = true
        self.playVideo(videoFilePath!)
    }
 
    func failedDownloadResources() {
    }
    
    func didCancelDownloadResources() {
    }
     */
    
    func closeDidTap() {
        self.avPlayer.pause()
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - videofilepath
    
    /*
    func getVideoFilePath(fileName: String) -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        var dataPath = documentsDirectory.stringByAppendingPathComponent("video")
        
        let fileManager = NSFileManager()
        if (!fileManager.fileExistsAtPath(dataPath)) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
                print("check")
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        } else {
            dataPath = dataPath + "/\(fileName)"
            print("dataPath: \(dataPath)")
            if (fileManager.fileExistsAtPath(dataPath)) {
                return dataPath
            } else {
                return nil
            }
        }
        
        return nil
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
