//
//  PreviewVideoViewController.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 12/9/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import UIKit
import ReplayKit
import Photos
import AVKit

class PreviewVideoViewController: UIViewController {
    
    var backgroundImageView: UIImageView = UIImageView()
    var previewImageView: UIImageView = UIImageView()
    
    var player: AVPlayerViewController?
    
    var homeButton: UIButton = UIButton()
    var shareButton: UIButton = UIButton()
    var playButton: UIButton = UIButton()
    
    var currentAsset: PHAsset?
    
    private var _prefersStatusBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        self.backgroundImageView.frame = self.view.frame
        self.backgroundImageView.image = UIImage(named: "preview_bg")
        
        self.view.addSubview(self.backgroundImageView)
        
        self.homeButton.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: 256.0, h: 249.0)
        self.homeButton.setImage(UIImage(named: "home_button"), for: .normal)
        self.homeButton.addTarget(self, action: #selector(PreviewVideoViewController.dismissController), for: .touchUpInside)
        
        self.shareButton.frame = Adapter.calculatedRectFromRatio(x: 398.0, y: 1886.0, w: 371.0 * 1.2, h: 158.0 * 1.2)
        self.shareButton.setImage(UIImage(named: "share_button"), for: .normal)
        
        self.view.addSubview(self.homeButton)
        self.view.addSubview(self.shareButton)
        
        self.previewImageView.frame = Adapter.calculatedRectFromRatio(x: 67.0, y: 620.0, w: 1108.0, h: 1108.0)
        self.previewImageView.layer.cornerRadius = 4.0
        self.previewImageView.layer.borderColor = UIColor.white.cgColor
        self.previewImageView.layer.borderWidth = CGFloat(4.0)
        self.previewImageView.clipsToBounds = true
        self.previewImageView.contentMode = .scaleAspectFill
        self.view.addSubview(self.previewImageView)
        
        self.playButton.frame = Adapter.calculatedRectFromRatio(x: 429.0, y: 990.0, w: 384.0, h: 384.0)
        self.playButton.setImage(UIImage(named: "play_button"), for: .normal)
        self.playButton.addTarget(self, action: #selector(PreviewVideoViewController.playVideo), for: .touchUpInside)
        self.view.addSubview(self.playButton)
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            if (status == PHAuthorizationStatus.authorized) {
                let allVidOptions = PHFetchOptions()
                allVidOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
                allVidOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let allVids = PHAsset.fetchAssets(with: allVidOptions)
                if let phAsset = allVids.lastObject {
                    self.currentAsset = phAsset
                    PHImageManager.default().requestImage(for: phAsset, targetSize: CGSize.init(width: 320.0, height: 320.0), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                        self.previewImageView.image = image
                    })
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get { return self._prefersStatusBarHidden }
        set { self._prefersStatusBarHidden = true }
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.player
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func dismissController() {
        self.setNeedsStatusBarAppearanceUpdate()
        ControllerManager.sharedInstance.presentMainController()
    }
    
    func playVideo() {
        if let asset = self.currentAsset {
            guard (asset.mediaType == PHAssetMediaType.video)
            else {
                return
            }
            PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: { asset, audioMix, info in
                let asset = asset as! AVURLAsset
                DispatchQueue.main.async {
                    let controller = VideoPreviewViewController(nibName: "VideoPreviewViewController", bundle: nil)
                    controller.url = asset.url
                    self.present(controller, animated: true) {
                        controller.checkVideo()
                    }
                }
            })
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        self.player?.dismiss(animated: true, completion: { _ in
            self.prefersStatusBarHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
        })
        print("Video Finished")
    }

}
