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

import FBSDKLoginKit
import FBSDKShareKit

import SwiftyJSON

class PreviewVideoViewController: UIViewController, FBSDKSharingDelegate {
    
    var backgroundImageView: UIImageView = UIImageView()
    var previewImageView: UIImageView = UIImageView()
    
    var player: AVPlayerViewController?
    
    var homeButton: UIButton = UIButton()
    var shareButton: UIButton = UIButton()
    var playButton: UIButton = UIButton()
    
    var currentAsset: PHAsset?
    var currentAssetUrl: URL?
    
    var uploadingView: UIView = UIView()
    
    private var _prefersStatusBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        
        self.backgroundImageView.frame = self.view.frame
        self.backgroundImageView.image = UIImage(named: "preview_bg")
        
        self.view.addSubview(self.backgroundImageView)
        
        self.homeButton.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: 256.0, h: 249.0)
        self.homeButton.setImage(UIImage(named: "home_button"), for: .normal)
        self.homeButton.addTarget(self, action: #selector(PreviewVideoViewController.dismissController), for: .touchUpInside)
        
        self.shareButton.frame = Adapter.calculatedRectFromRatio(x: 394.0, y: 1886.0, w: 371.0 * 1.2, h: 158.0 * 1.2)
        self.shareButton.setImage(UIImage(named: "share_button"), for: .normal)
        self.shareButton.addTarget(self, action: #selector(PreviewVideoViewController.checkFBReadPermissions), for: .touchUpInside)
        
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
                    let identifier = phAsset.localIdentifier
                    let id = identifier.substring(to: identifier.index(identifier.startIndex, offsetBy: 36))
                    print(identifier)
                    self.currentAssetUrl = URL(string: "assets-library://asset/asset.MP4?id=\(id)&ext=MP4")
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
        /*
        if let url = self.currentAssetUrl {
        } else {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        }
         */
    }
    
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.currentAssetUrl = info[UIImagePickerControllerReferenceURL] as! URL
        print(self.currentAssetUrl)
        picker.dismiss(animated: true, completion: nil)
    }
     */
    
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
                    print(asset.url.absoluteString)
                    // self.currentAssetUrl = asset.url
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

    // MARK: FB
    
    func popupFBShareDidTap() {
        if let _ = FBSDKAccessToken.current() {
            if FBSDKAccessToken.current().hasGranted("publish_actions") {
                self.shareFacebookResult()
            } else {
                let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                    
                    loginManager.loginBehavior = FBSDKLoginBehavior.browser
                    
                    loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self, handler: { (result, error) in
                        if (error != nil) {
                            
                        } else {
                            let result: FBSDKLoginManagerLoginResult = result!
                            if (result.isCancelled) {
                            } else if (result.declinedPermissions.contains("publish_actions")) {
                            } else {
                                self.shareFacebookResult()
                            }
                        }
                    })
            }
        } else {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            loginManager.loginBehavior = FBSDKLoginBehavior.browser
            
            loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self, handler: { (result, error) in
                if (error != nil) {
                    
                } else {
                    let result: FBSDKLoginManagerLoginResult = result!
                    if (result.isCancelled) {
                    } else if (result.declinedPermissions.contains("publish_actions")) {
                    } else {
                        self.shareFacebookResult()
                    }
                }
            })
        }
        /*
        if let _ = FBSDKAccessToken.current() {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,gender,link,first_name,last_name"], httpMethod: "GET")
            let connection = FBSDKGraphRequestConnection()
            connection.add(request, completionHandler: { (conn, result, error) -> Void in
                if (error != nil) {
                    print("\(error?.localizedDescription)")
                } else {
                    var json = JSON(result)
                    
                    if let firstname = json["first_name"].string as AnyObject? {
                        DataManager.sharedInstance.setObjectForKey(value: firstname, key: "first_name")
                    }
                    
                    if let lastname = json["last_name"].string as AnyObject? {
                        DataManager.sharedInstance.setObjectForKey(value: lastname, key: "last_name")
                    }
                    
                    if let email = json["email"].string as AnyObject? {
                        DataManager.sharedInstance.setObjectForKey(value: email, key: "email")
                    }
                    
                    if let gender = json["gender"].string as AnyObject? {
                        DataManager.sharedInstance.setObjectForKey(value: gender, key: "gender")
                    }
                    
                    if let link = json["link"].string as AnyObject? {
                        DataManager.sharedInstance.setObjectForKey(value: link, key: "link")
                    }
                    
                    self.shareFacebookResult()
                }
            })
            
            connection.start()
        } else {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            loginManager.loginBehavior = FBSDKLoginBehavior.browser
            
            loginManager.logIn(withReadPermissions: ["public_profile", "user_about_me"], from: self, handler: {
                (result, error) in
                if (error != nil) {
                    // fb login error
                } else {
                    let result: FBSDKLoginManagerLoginResult = result!
                    if (result.isCancelled) {
                        // fb login cancelled
                    } else if (result.declinedPermissions.contains("public_profile") || result.declinedPermissions.contains("user_about_me")) {
                        // declined "public_profile", "email" or "user_about_me"
                    } else {
                        // TODO: api to update facebookid-nontoken
                        _ = FBSDKAccessToken.current().userID
                        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,gender,link,first_name,last_name"], httpMethod: "GET")
                        let connection = FBSDKGraphRequestConnection()
                        connection.add(request, completionHandler: { (conn, result, error) -> Void in
                            if (error != nil) {
                                print("\(error?.localizedDescription)")
                            } else {
                                var json = JSON(result)
                                
                                // var params = Dictionary<String, AnyObject>()
                                
                                if let firstname = json["first_name"].string as AnyObject? {
                                    DataManager.sharedInstance.setObjectForKey(value: firstname, key: "first_name")
                                }
                                
                                if let lastname = json["last_name"].string as AnyObject? {
                                    DataManager.sharedInstance.setObjectForKey(value: lastname, key: "last_name")
                                }
                                
                                if let email = json["email"].string as AnyObject? {
                                    DataManager.sharedInstance.setObjectForKey(value: email, key: "email")
                                }
                                
                                if let gender = json["gender"].string as AnyObject? {
                                    DataManager.sharedInstance.setObjectForKey(value: gender, key: "gender")
                                }
                                
                                if let link = json["link"].string as AnyObject? {
                                    DataManager.sharedInstance.setObjectForKey(value: link, key: "link")
                                }
                                
                                // OtificationHTTPService.sharedInstance.updateFacebookIDNonToken(KeychainWrapper.defaultKeychainWrapper().stringForKey("fbuid")!)
                                
                                // self.shareFacebookResult()
                                // self.getPublishPermission()
                            }
                        })
                        connection.start()
                    }
                }
            })
        }
         */
    }
    
    func checkFBReadPermissions() {
        if let _ = FBSDKAccessToken.current() {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,gender,link,first_name,last_name"], httpMethod: "GET")
            let connection = FBSDKGraphRequestConnection()
            connection.add(request, completionHandler: { (conn, result, error) -> Void in
                if (error != nil) {
                    print("\(error?.localizedDescription)")
                } else {
                    self.checkFBPublishPermissions()
                }
            })
            connection.start()
        } else {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            loginManager.loginBehavior = FBSDKLoginBehavior.browser
            
            loginManager.logIn(withReadPermissions: ["public_profile", "user_about_me"], from: self, handler: {
                (result, error) in
                if (error != nil) {
                    // fb login error
                } else {
                    let result: FBSDKLoginManagerLoginResult = result!
                    if (result.isCancelled) {
                        // fb login cancelled
                    } else if (result.declinedPermissions.contains("public_profile") || result.declinedPermissions.contains("user_about_me")) {
                        // declined "public_profile", "email" or "user_about_me"
                    } else {
                        self.checkFBPublishPermissions()
                    }
                }
            })
        }
    }
    
    func checkFBPublishPermissions() {
        if FBSDKAccessToken.current().hasGranted("publish_actions") {
            self.shareFacebookResult()
        } else {
            let loginManager = FBSDKLoginManager()
            
                loginManager.loginBehavior = FBSDKLoginBehavior.browser
                
                loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self, handler: { (result, error) in
                    if (error != nil) {
                        
                    } else {
                        let result: FBSDKLoginManagerLoginResult = result!
                        if (result.isCancelled) {
                        } else if (result.declinedPermissions.contains("publish_actions")) {
                        } else {
                            self.shareFacebookResult()
                        }
                    }
                })
        }
    }
    
    func shareFacebookResult() {
        
        let video = FBSDKShareVideo(videoURL: self.currentAssetUrl)
        
        let videoContent = FBSDKShareVideoContent()
        videoContent.video = video
        
        FBSDKShareAPI.share(with: videoContent, delegate: self)
        
        self.uploadingView = UIView(frame: self.view.frame)
        self.uploadingView.backgroundColor = UIColor.black
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = view.center
        activity.startAnimating()
        
        let label = UILabel(frame: CGRect.init(x: 0.0, y: view.center.y + 40.0, width: view.frame.size.width, height: 50.0))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0, weight: 0.85)
        label.text = "Uploading Video ..."
        
        let description = UILabel(frame: CGRect.init(x: 0.0, y: view.center.y + 65.0, width: view.frame.size.width, height: 50.0))
        description.textAlignment = .center
        description.textColor = UIColor.white
        description.numberOfLines = 2
        description.font = UIFont.systemFont(ofSize: 12.0)
        description.text = "It may take a few minute to uploading your video."
        
        self.uploadingView.addSubview(activity)
        self.uploadingView.addSubview(label)
        self.uploadingView.addSubview(description)
        
        self.view.addSubview(self.uploadingView)
        
        /*
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogMode.native
        dialog.shareContent = videoContent
        dialog.delegate = self
        dialog.fromViewController = self
        
        dialog.show()
         */
        
        /*
        let contentImg = NSURL(string: actionInfo.shareImageUrlString!)
        let contentURL = NSURL(string: actionInfo.shareUrl!)
        let contentTitle = actionInfo.shareTitle!
        let contentDescription = actionInfo.shareDesription!
        
        let photoContent: FBSDKShareLinkContent = FBSDKShareLinkContent()
        
        photoContent.contentURL = contentURL
        photoContent.contentTitle = contentTitle
        photoContent.contentDescription = contentDescription
        photoContent.imageURL = contentImg
        
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogMode.FeedBrowser
        dialog.shareContent = photoContent
        dialog.delegate = self
        dialog.fromViewController = self
        
        dialog.show()
         */
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("didCancel")
        self.uploadingView.removeFromSuperview()
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("didFailWithError: \(error.localizedDescription)")
        self.uploadingView.removeFromSuperview()
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("didCompleteWithResults")
        self.uploadingView.removeFromSuperview()
        ControllerManager.sharedInstance.presentMainController()
        /*
        if let _ = results["postId"] {
            OtificationHTTPService.sharedInstance.saveFBShare(results["postId"] as! String)
            OtificationHTTPService.sharedInstance.shareResult()
        }
         */
    }
    
}
