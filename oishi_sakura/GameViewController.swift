//
//  GameViewController.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/17/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import ReplayKit
import AVFoundation
import GoogleMobileVision
import SwiftKeychainWrapper
import Photos

enum SakuraOrigin {
    case Mouth, Eyes, Ears, None
}

enum RecordingState {
    case Stop, Start, State1, State2, State3, End
}

class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, RPScreenRecorderDelegate, RPPreviewViewControllerDelegate {
    
    // MARK: - UI elements
    /*
    @IBOutlet weak var placeHolder: UIView!
    @IBOutlet weak var overlay: UIView!
     */
    
    var placeHolder: UIView = UIView()
    var overlay: UIView = UIView()
    
    var overlayWindow: UIWindow?
    
    var swapCameraButton: UIButton = UIButton()
    var eyesToggleButton: UIButton = UIButton()
    var mouthToggleButton: UIButton = UIButton()
    var earsToggleButton: UIButton = UIButton()
    var recordButton: UIButton = UIButton()
    
    var frame: UIImageView = UIImageView()
    var iceFrames: [UIImageView] = [UIImageView]()
    var endSceneImageView: UIImageView = UIImageView()
    
    // MARK: - Video objects
    
    var session: AVCaptureSession?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var lastKnownDeviceOrientation: UIDeviceOrientation?
    
    // MARK: - Detector
    
    var faceDetector: GMVDetector?
    
    // MARK: - Game scene
    
    var scene: GameScene?
    var skView: SKView?
    
    // MARK: - Replay Kit
    
    var recording: Bool = false
    var prepare: Bool = false
    
    // MARK: - sakura position
    
    var origin: SakuraOrigin = .None
    
    // MARK: - face
    
    private var leftCheekImageView: UIImageView = UIImageView()
    private var rightCheekImageView: UIImageView = UIImageView()
    
    private var trackingIds: Dictionary<UInt, Bool> = Dictionary<UInt, Bool>()
    
    private var addedCheeks: Bool = false
    
    // MARK: - camera
    
    private var frontCamera: Bool = true
    
    // MARK: - testing
    
    private var versionLabel: UILabel = UILabel()
    
    // MARK: - timer & state
    
    private var timer: Timer?
    private var timerCounter: Double = -1.0
    private var state: RecordingState = .Stop
    
    // MARK: - settings flag
    
    private var setup: Bool = false
    var xScale: CGFloat = 1
    var yScale: CGFloat = 1
    var videoBox = CGRect.zero
    
    // MARK: - current state
    
    private var currentState: Int = 0
    private var lockStateChange: Bool = false
    
    private var didCancel: Bool = false
    private var showAlert: Bool = false
    
    // MARK: - frame
    private var realFrame: CGRect = CGRect.zero
    
    // MARK: -
    var blackView: UIView?
    
    // MARK: - bg sound
    
    var isSoundPlaying: Bool = false
    var backgroundMusicPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isiPad {
            self.realFrame = CGRect.init(x: 0.0, y: 0.0, width: 540.0, height: 960.0)
        } else {
            self.realFrame = self.view.frame
        }
        
        // video
        self.session = AVCaptureSession()
        self.session?.sessionPreset = AVCaptureSessionPresetiFrame960x540
        self.updateCameraSelection()
        
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        
        self.setupVideoProcessing()
        self.setupCameraPreview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isiPad {
            self.view.frame = CGRect.init(x: 114.0, y: 32.0, width: 540.0, height: 960.0)
        }
        
        self.placeHolder.frame = self.realFrame
        self.overlay.frame = self.realFrame
        
        self.view.addSubview(self.placeHolder)
        self.view.addSubview(self.overlay)
        
        self.previewLayer?.frame = self.view.layer.bounds
        self.previewLayer?.position = CGPoint(x: (self.previewLayer?.frame)!.midX, y: (self.previewLayer?.frame)!.midY)
        
        self.frame.frame = self.overlay.frame
        self.frame.image = UIImage(named: "frame")
        self.overlay.addSubview(self.frame)
        
        for index in 0...2 {
            let imageView = UIImageView(frame: self.overlay.frame)
            imageView.image = UIImage(named: "ice_\(index+1)")
            imageView.alpha = 0.0
            self.iceFrames.append(imageView)
        }
        
        // gmvdetector
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorFaceMinSize: 0.5,
            GMVDetectorFaceTrackingEnabled: true,
            GMVDetectorFaceMode: GMVDetectorFaceModeOption.fastMode.rawValue,
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue
        ]
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        // game scene
        self.skView = SKView(frame: self.realFrame)
        self.skView?.backgroundColor = UIColor.clear
        
        self.scene = GameScene(size: UIScreen.main.bounds.size)
        self.scene?.scaleMode = .aspectFill
        self.scene?.backgroundColor = UIColor.clear
        self.skView?.presentScene(self.scene)
       
        self.skView?.ignoresSiblingOrder = true
        
        /*
        self.skView?.showsFPS = true
        self.skView?.showsNodeCount = true
         */
        
        self.view.addSubview(self.skView!)
        self.view.bringSubview(toFront: self.skView!)
        
        // face
        self.leftCheekImageView.contentMode = .scaleAspectFit
        self.rightCheekImageView.contentMode = .scaleAspectFit
        
        // end scene
        self.endSceneImageView.frame = self.overlay.frame
        self.endSceneImageView.image = UIImage(named: "end_scene")
        self.endSceneImageView.contentMode = .scaleAspectFit
        self.endSceneImageView.alpha = 0.0
        
        self.updateCameraSelection()
        self.setupCameraPreview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if (status == AVAuthorizationStatus.denied) {
                ControllerManager.sharedInstance.presentIndexController()
        } else if (status == AVAuthorizationStatus.notDetermined) {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
                if (!granted) {
                    DispatchQueue.main.sync {
                        ControllerManager.sharedInstance.presentIndexController()
                    }
                    return
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
        
        AdapterGoogleAnalytics.sharedInstance.sendGoogleAnalyticsEventTracking(category: .Page, action: .Opened, label: "home")
        
        // overlay window
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isiPad {
            self.overlayWindow = UIWindow(frame: CGRect.init(x: 114.0, y: 32.0, width: 540.0, height: 960.0))
        } else {
            self.overlayWindow = UIWindow(frame: (self.view.window?.frame)!)
        }
        
        self.overlayWindow?.windowLevel = UIWindowLevelAlert
        self.overlayWindow?.isHidden = false
        self.overlayWindow?.backgroundColor = UIColor.clear
        self.overlayWindow?.makeKeyAndVisible()
        
        self.initUIElements()
        
        // random initial selected sakura emitter position
        
        let randomUInt: UInt32 = arc4random_uniform(3)
        let random: Int = Int(randomUInt)
        let button: UIButton = UIButton()
        button.tag = random
        self.toggleButton(button: button)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        self.stopBackgroundMusic()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        self.session?.stopRunning()
    }
    
    /*
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
     */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - AVCaptureVideoPreviewLayer Helper method
    
    func scaledRect(rect: CGRect, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGRect {
        let resultRect = CGRect(x: rect.origin.x * xScale, y: rect.origin.y * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
        return resultRect
    }
    
    func scaledPoint(point: CGPoint, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGPoint {
        let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: point.y * yScale + offset.y)
        return resultPoint
    }
    
    func scaledPointForScene(point: CGPoint, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGPoint {
        if ((UIApplication.shared.delegate) as! AppDelegate).isiPad {
            let resultPoint = CGPoint(x: (point.x + 114.0) * xScale + offset.x, y: UIScreen.main.bounds.size.height - ((point.y + 32.0) * yScale + offset.y))
            return resultPoint
        } else {
            let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: UIScreen.main.bounds.size.height - (point.y * yScale + offset.y))
            return resultPoint
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer)
        let avCaptureDevicePosition: AVCaptureDevicePosition = self.frontCamera ? AVCaptureDevicePosition.front : AVCaptureDevicePosition.back
        
        let orientation = GMVUtility.imageOrientation(from: UIDevice.current.orientation, with: avCaptureDevicePosition, defaultDeviceOrientation: .portrait)
        
        if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .portraitUpsideDown) {
            self.scene?.removeAllChildren()
            return
        }
        
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorImageOrientation: orientation.rawValue
        ]
        
        let faces = self.faceDetector?.features(in: image, options: options) as! [GMVFaceFeature]
        
        let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false)
        let parentFrameSize = self.previewLayer?.frame.size
        
        // if (!self.setup) {
        self.videoBox.size.width = (parentFrameSize?.width)!
        self.videoBox.size.height = clap.size.width * ((parentFrameSize?.width)! / clap.size.height)
        self.videoBox.origin.x = (self.videoBox.size.width - (parentFrameSize?.width)!) / 2
        self.videoBox.origin.y = ((parentFrameSize?.height)! - self.videoBox.size.height) / 2

        self.xScale = self.videoBox.size.width / clap.size.height;
        self.yScale = self.videoBox.size.height / clap.size.width;
        
        self.setup = true
        // }
        
        var saveTrackingIds: Dictionary<UInt, Bool> = Dictionary<UInt, Bool>()
        
        DispatchQueue.main.sync {
            
            if (faces.count == 0) {
                if let soundNode = self.scene?.childNode(withName: "sound") {
                    soundNode.removeFromParent()
                }
                self.stopBackgroundMusic()
                self.scene?.noPointDetected()
                self.removeCheeks()
                return
            }
                
            if (self.origin == .None) {
                DispatchQueue.main.async {
                    if let soundNode = self.scene?.childNode(withName: "sound") {
                        soundNode.removeFromParent()
                    }
                }
                self.stopBackgroundMusic()
                self.scene?.noPointDetected()
                self.removeCheeks()
                return
            }
            
            // Display detected features in overlay.
            for (index, face) in faces.enumerated() {
                
                if (index >= 2) {
                    return
                }
                
                /* check origin of desired emitter node
                    1. mouth
                    2. ears
                    3. eyes
                 */
                
                // TODO: - save face tracking id
                saveTrackingIds[face.trackingID] = true
                // print("save trackingId: \(face.trackingID)")
                if let saved = self.trackingIds[face.trackingID] {
                    
                    if (self.origin != .None) {
                        // TODO: - create emitter nodes
                        
                        if (!self.isSoundPlaying && !self.prepare) {
                            self.playBackgroundMusic(filename: "")
                            if (!self.recording) {
                                let randomNum: UInt32 = arc4random_uniform(2)
                                let index: Int = Int(randomNum)
                                print("random: \(index)")
                                if (index == 0) {
                                    self.overlay.addSubview(self.iceFrames[0])
                                    UIView.animate(withDuration: 0.25, animations: {
                                        self.iceFrames[0].alpha = 0.0
                                        self.iceFrames[0].alpha = 1.0
                                    })
                                }
                            }
                        }
                        
                        if (self.origin == .Mouth) {
                            if (face.hasMouthPosition == true) {
                                let point = self.scaledPointForScene(point: face.mouthPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                                
                                if (self.recording) {
                                    self.scene?.createMouthEmitterNodes(trackingID: face.trackingID, state: self.currentState)
                                } else {
                                    if (!self.prepare) {
                                        self.scene?.createMouthEmitterNodes(trackingID: face.trackingID, state: -99)
                                    }
                                }
                                if (!self.prepare) {
                                    self.scene?.pointDetected(face: face, atPoint: point, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                                }
                            }
                        } else if (self.origin == .Ears) {
                            if (face.hasLeftEarPosition && face.hasRightEarPosition) {
                                let lpoint = self.scaledPointForScene(point: face.leftEarPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                                let rpoint = self.scaledPointForScene(point: face.rightEarPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                                
                                if (self.recording) {
                                    self.scene?.createEarsEmitterNodes(trackingID: face.trackingID, state: self.currentState)
                                } else {
                                    if (!self.prepare) {
                                        self.scene?.createEarsEmitterNodes(trackingID: face.trackingID, state: -99)
                                    }
                                }
                                
                                if (!self.prepare) {
                                    self.scene?.earsPointDetected(face: face, lpos: lpoint, rpos: rpoint, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                                }
                            }
                        } else if (self.origin == .Eyes) {
                            if (face.hasLeftEyePosition && face.hasRightEyePosition) {
                                let lpoint = self.scaledPointForScene(point: face.leftEyePosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                                let rpoint = self.scaledPointForScene(point: face.rightEyePosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                                
                                if (self.recording) {
                                    self.scene?.createEyesEmitterNodes(trackingID: face.trackingID, state: self.currentState)
                                } else {
                                    if (!self.prepare) {
                                        self.scene?.createEyesEmitterNodes(trackingID: face.trackingID, state: -99)
                                    }
                                }
                                
                                if (!self.prepare) {
                                    self.scene?.eyesPointDetected(face: face, lpos: lpoint, rpos: rpoint, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                                }
                            }
                        }
                    
                        // Cheeks
                        if (face.hasLeftCheekPosition && face.hasRightCheekPosition) {
                            // TODO: - move cheek image view to skspritenode in game scene
                            var editedLeftCheekPosition = face.leftCheekPosition
                            editedLeftCheekPosition.y -= (0.065 * face.bounds.size.height)
                            
                            var editedRightCheekPosition = face.rightCheekPosition
                            editedRightCheekPosition.y -= (0.065 * face.bounds.size.height)
                            
                            let lpoint = self.scaledPointForScene(point: editedLeftCheekPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                            let rpoint = self.scaledPointForScene(point: editedRightCheekPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                            
                            if (self.recording) {
                                self.scene?.cheeksDetected(face: face, state: self.currentState, leftCheekPoint: lpoint, rightCheekPoint: rpoint)
                            } else {
                                self.scene?.cheeksDetected(face: face, state: -99, leftCheekPoint: lpoint, rightCheekPoint: rpoint)
                            }
                            
                            if (!self.addedCheeks && !self.prepare) {
                                self.addedCheeks = true
                            }
                        }
                    }
                } else {
                    // TODO: - wait for detection 2nd time
                }
            }
        }
        
        // TODO: - check disappeared tracking id then remove all nodes of that tracking id
        if saveTrackingIds.count > self.trackingIds.count {
            for key in saveTrackingIds.keys {
                print("save new trakcing id: \(key)")
                self.trackingIds[key] = true
            }
        } else {
            for key in self.trackingIds.keys {
                if (saveTrackingIds[key] == nil) {
                    print("saveTackingIds with key: \(key) disappeared")
                    // removed face
                    self.trackingIds[key] = nil
                    self.scene?.removeAllNode(prefix: key)
                } else {
                    self.trackingIds[key] = true
                }
            }   
        }
        
        if (self.lockStateChange) {
            StateManager.sharedInstance.increaseState()
            self.lockStateChange = false
        }
    }
    
    // MARK: - cheek detected
    
    func cheeksDetected(faceRect: CGRect, leftCheekPoint: CGPoint, rightCheekPoint: CGPoint) {
        self.leftCheekImageView.center = leftCheekPoint
        self.rightCheekImageView.center = rightCheekPoint
    }
    
    func removeCheeks() {
        if (self.addedCheeks) {
            self.iceFrames[0].removeFromSuperview()
            self.leftCheekImageView.removeFromSuperview()
            self.rightCheekImageView.removeFromSuperview()
            self.addedCheeks = false
        }
    }
    
    // MARK: - ReplayKit
    
    func startRecording() {
        let recorder = RPScreenRecorder.shared()
        
        self.prepare = true
        self.stopBackgroundMusic()
        
        self.removeCheeks()
        self.scene?.removeAllChildren()
        self.scene?.resetEmitterNodes()
        
        self.iceFrames[0].removeFromSuperview()
        
        recorder.startRecording(withMicrophoneEnabled: true, handler: { error in
            if let error = error {
                print(error.localizedDescription)
                self.prepare = false
            } else {
                
                AdapterGoogleAnalytics.sharedInstance.sendGoogleAnalyticsEventTracking(category: .Page, action: .Opened, label: "recording")
                AdapterHTTPService.sharedInstance.saveGameNonToken()
                
                self.swapCameraButton.isHidden = true
                self.eyesToggleButton.isHidden = true
                self.mouthToggleButton.isHidden = true
                self.earsToggleButton.isHidden = true
                
                self.scene?.changeLightEmitterNode(pink: true)
                self.startTimer()
                self.recording = true
                self.prepare = false
                print("recording video")
            }
        })
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.shared()
        
        recorder.stopRecording(handler: { (preview, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let preview = preview {
                // self.placeHolder.removeFromSuperview()
                // self.overlayView.removeFromSuperview()
                
                self.overlayWindow?.isHidden = true
                
                self.swapCameraButton.removeFromSuperview()
                self.eyesToggleButton.removeFromSuperview()
                self.mouthToggleButton.removeFromSuperview()
                self.earsToggleButton.removeFromSuperview()
                self.recordButton.removeFromSuperview()
                
                self.swapCameraButton.isHidden = false
                self.eyesToggleButton.isHidden = false
                self.mouthToggleButton.isHidden = false
                self.earsToggleButton.isHidden = false
                self.recordButton.isHidden = false
                
                self.currentState = 0
                StateManager.sharedInstance.resetState()
                
                self.prepare = true
        
                self.removeCheeks()
                self.scene?.removeAllChildren()
                self.scene?.resetEmitterNodes()
                
                self.prepare = false
                
                self.origin = .None
                
                preview.previewControllerDelegate = self
                preview.modalPresentationStyle = .fullScreen
                preview.popoverPresentationController?.sourceView = self.view
                preview.popoverPresentationController?.delegate = self
                
                /*
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if appDelegate.isiPad {
                    preview.popoverPresentationController?.delegate = self
                }
                 */
                
                DispatchQueue.main.async {
                    if let soundNode = self.scene?.childNode(withName: "sound") {
                        soundNode.removeFromParent()
                    }
                }
                
                let status = PHPhotoLibrary.authorizationStatus()
        
                if (status == PHAuthorizationStatus.denied) {
                    // TODO: -
                    self.endSceneImageView.removeFromSuperview()
                    self.recording = false
                    self.viewDidAppear(true)
                    
                    /*
                    let randomUInt: UInt32 = arc4random_uniform(3)
                    let random: Int = Int(randomUInt)
                    let button: UIButton = UIButton()
                    button.tag = random
                    self.toggleButton(button: button)
                     */
                } else if (status == .notDetermined) {
                    PHPhotoLibrary.requestAuthorization { (status) -> Void in
                        if (status == PHAuthorizationStatus.authorized) {
                            self.present(preview, animated: true, completion: { completed in
                                if let origin = DataManager.sharedInstance.getObjectForKey(key: "emitter_origin") {
                                    AdapterHTTPService.sharedInstance.saveGameComplete(emitterOrigin: origin as! String)
                                } else {
                                    print("no emitter_origin saved")
                                }
                                self.endSceneImageView.removeFromSuperview()
                                if let round = KeychainWrapper.standard.integer(forKey: "round") {
                                    if (round >= 3) {
                                        KeychainWrapper.standard.set(1, forKey: "round")
                                    } else {
                                        KeychainWrapper.standard.set(round + 1, forKey: "round")
                                    }
                                }
                            })
                            self.recording = false
                        } else {
                            // TODO: -
                            DispatchQueue.main.async {
                                self.recording = false
                                self.endSceneImageView.removeFromSuperview()
                                self.viewDidAppear(true)
                            }
                            
                            let randomUInt: UInt32 = arc4random_uniform(3)
                            let random: Int = Int(randomUInt)
                            let button: UIButton = UIButton()
                            button.tag = random
                            self.toggleButton(button: button)
                        }
                    }
                } else if (status == .authorized) {
                    self.present(preview, animated: true, completion: { completed in
                        if let origin = DataManager.sharedInstance.getObjectForKey(key: "emitter_origin") {
                            AdapterHTTPService.sharedInstance.saveGameComplete(emitterOrigin: origin as! String)
                        } else {
                            print("no emitter_origin saved")
                        }
                        self.endSceneImageView.removeFromSuperview()
                        if let round = KeychainWrapper.standard.integer(forKey: "round") {
                            if (round >= 3) {
                                KeychainWrapper.standard.set(1, forKey: "round")
                            } else {
                                KeychainWrapper.standard.set(round + 1, forKey: "round")
                            }
                        }
                    })
                    self.recording = false
                }
                
            }
        })
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        
        DispatchQueue.main.async {
            
            for type in activityTypes {
                print(type)
            }
            
            if activityTypes.count > 0 {
                // save
                // present preview
                self.overlayWindow?.isHidden = true
                
                self.swapCameraButton.isHidden = false
                self.eyesToggleButton.isHidden = false
                self.mouthToggleButton.isHidden = false
                self.earsToggleButton.isHidden = false
                self.recordButton.isHidden = false
                
                self.addDownloadingView()
                
                self.origin = .None
                self.overlayWindow?.isHidden = true
                
                previewController.dismiss(animated: true, completion: { completed in
                    
                    self.origin = .None
                    self.overlayWindow?.isHidden = true
                    
                    // AdapterHTTPService.sharedInstance.saveVideo()
                    
                    Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(GameViewController.presentPreviewVideoController), userInfo: nil, repeats: false)
                    
                    /*
                    self.present(PreviewVideoViewController(nibName: "PreviewVideoViewController", bundle: nil), animated: true, completion: { completed in
                        self.origin = .None
                    })
                     */
                })
            } else {
                // no save action
                // present alert view
                
                previewController.dismiss(animated: true, completion: { _ in
                    self.didCancel = false
                    self.viewDidAppear(true)
                })
                /*
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if appDelegate.isiPad {
                    previewController.dismiss(animated: true, completion: { _ in
                        self.didCancel = false
                        self.viewDidAppear(true)
                    })
                } else {
                    previewController.dismiss(animated: true, completion: { _ in
                        self.didCancel = false
                        self.viewDidAppear(true)
                    })
                }
                 */
            }
            
        }
    }
    
    func addDownloadingView() {
        let view = UIView(frame: self.realFrame)
        view.backgroundColor = UIColor.black
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = view.center
        activity.startAnimating()
        
        let label = UILabel(frame: CGRect.init(x: 0.0, y: view.center.y + 40.0, width: view.frame.size.width, height: 50.0))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0, weight: 0.85)
        label.text = "Processing Video ..."
        
        view.addSubview(activity)
        view.addSubview(label)
        
        self.overlay.addSubview(view)
    }
    
    func presentPreviewVideoController() {
        ControllerManager.sharedInstance.presentPreviewVideoController()
    }
    
    // MARK: - change state while recording
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameViewController.changeState), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.stopRecording()
        self.timer?.invalidate()
        self.timerCounter = -1.0
        for index in 0...2 {
            self.iceFrames[index].removeFromSuperview()
        }
    }
    
    func changeState() {
        self.timerCounter += 0.5
        // print("time @ \(self.timerCounter)")
        if (self.timerCounter == 0.0) {
            if (self.timerCounter == 0.0) {
                self.lockStateChange = true
                for index in 0...2 {
                    self.iceFrames[index].removeFromSuperview()
                    self.iceFrames[index].alpha = 0.0
                }
            }
            // start recording -> 2.0 s
            // white sakura, pink light ray, cheek 1, no ice frame
            // print("start recording")
        } else if (self.timerCounter >= 4.5 && self.timerCounter < 5.5) {
            // 1.5s
            // pink sakura, blue light ray, cheek 2, ice frame level 1
            // print("change to state 1")
            if (self.timerCounter == 4.5) {
                self.lockStateChange = true
                self.currentState += 1
                self.scene?.changeLightEmitterNode(pink: false)
                self.overlay.addSubview(self.iceFrames[0])
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[0].alpha = 0.0
                    self.iceFrames[0].alpha = 1.0
                })
            }
        } else if (self.timerCounter == 5.5 && self.timerCounter < 6.5) {
           // 1.5s
            // pink sakura, blue light ray, cheek 2, ice frame level 2
            // print("change to state 2")
            if (self.timerCounter == 5.5) {
                self.lockStateChange = true
                self.currentState += 1
                self.overlay.addSubview(self.iceFrames[1])
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[1].alpha = 0.0
                    self.iceFrames[1].alpha = 1.0
                })
            }
        } else if (self.timerCounter == 6.5 && self.timerCounter < 8.0) {
           // 1.5s
            // pink sakura, blue light ray, cheek 2, ice frame level 3
            // print("change to state 3")
            if (self.timerCounter == 6.5) {
                self.lockStateChange = true
                self.currentState += 1
                self.overlay.addSubview(self.iceFrames[2])
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[2].alpha = 0.0
                    self.iceFrames[2].alpha = 1.0
                })
            }
        } else if (self.timerCounter == 8.0 && self.timerCounter < 9.5) {
            // 0.5s
            // show end screen
            // print("show end screen")
            if (self.timerCounter == 8.0) {
                self.removeCheeks()
                self.overlay.addSubview(self.endSceneImageView)
                self.origin = .None
                self.recordButton.removeFromSuperview()
                self.scene?.removeAllChildren()
                UIView.animate(withDuration: 0.25, animations: {
                    self.endSceneImageView.alpha = 0.0
                    self.endSceneImageView.alpha = 1.0
                })
            }
        } else if (self.timerCounter == 9.5) {
            // stop recording
            // print("stop recording")
            self.scene?.changeLightEmitterNode(pink: true)
            self.stopTimer()
        }
    }
    
    func immediateStopRecording() {
        self.timer?.invalidate()
        self.timerCounter = -1.0
        for index in 0...2 {
            self.iceFrames[index].removeFromSuperview()
        }
        self.removeCheeks()
        self.overlay.addSubview(self.endSceneImageView)
        self.origin = .None
        self.recordButton.removeFromSuperview()
        
//        DispatchQueue.main.async {
//            self.scene?.removeAllChildren()
//        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.endSceneImageView.alpha = 0.0
            self.endSceneImageView.alpha = 1.0
        })
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(GameViewController.stopRecording), userInfo: nil, repeats: false)
    }
    
    // MARK: - Init UI elements
    
    func initUIElements() {
        let buttonSize = CGSize(width: 199.0, height: 199.0)
        
        self.swapCameraButton.removeFromSuperview()
        self.eyesToggleButton.removeFromSuperview()
        self.mouthToggleButton.removeFromSuperview()
        self.earsToggleButton.removeFromSuperview()
        
        self.swapCameraButton.frame = Adapter.calculatedRectFromRatio(x: 1015.0, y: 48.0, w: 211.0, h: 201.0)
        self.eyesToggleButton.frame = Adapter.calculatedRectFromRatio(x: 1014.0, y: 362.0, w: buttonSize.width, h: buttonSize.height)
        self.mouthToggleButton.frame = Adapter.calculatedRectFromRatio(x: 1014.0, y: 586.0, w: buttonSize.width, h: buttonSize.height)
        self.earsToggleButton.frame = Adapter.calculatedRectFromRatio(x: 1014.0, y: 814.0, w: buttonSize.width, h: buttonSize.height)
        self.recordButton.frame = Adapter.calculatedRectFromRatio(x: 456.0, y: 1872.0, w: 328.0, h: 318.0)
        
        self.swapCameraButton.layer.zPosition = 10000
        self.eyesToggleButton.layer.zPosition = 10000
        self.mouthToggleButton.layer.zPosition = 10000
        self.earsToggleButton.layer.zPosition = 10000
        self.recordButton.layer.zPosition = 10000
        
        self.swapCameraButton.tag = 99
        self.eyesToggleButton.tag = 0
        self.mouthToggleButton.tag = 1
        self.earsToggleButton.tag = 2
        self.recordButton.tag = 3
        
        self.swapCameraButton.setImage(UIImage(named: "swap_camera_button"), for: .normal)
        self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
        self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
        self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
        self.recordButton.setImage(UIImage(named: "start_record_button"), for: .normal)
        
        self.swapCameraButton.addTarget(self, action: #selector(GameViewController.toggleButton(button:)), for: .touchUpInside)
        self.eyesToggleButton.addTarget(self, action: #selector(GameViewController.toggleButton(button:)), for: .touchUpInside)
        self.mouthToggleButton.addTarget(self, action: #selector(GameViewController.toggleButton(button:)), for: .touchUpInside)
        self.earsToggleButton.addTarget(self, action: #selector(GameViewController.toggleButton(button:)), for: .touchUpInside)
        self.recordButton.addTarget(self, action: #selector(GameViewController.toggleButton(button:)), for: .touchUpInside)
        
        self.overlayWindow?.addSubview(self.swapCameraButton)
        self.overlayWindow?.addSubview(self.eyesToggleButton)
        self.overlayWindow?.addSubview(self.mouthToggleButton)
        self.overlayWindow?.addSubview(self.earsToggleButton)
        self.overlayWindow?.addSubview(self.recordButton)
        
        self.versionLabel.frame.origin = CGPoint(x: 10.0, y: 0.0)
        self.versionLabel.font = UIFont.systemFont(ofSize: 30.0)
        self.versionLabel.textColor = UIColor.white
        self.versionLabel.text = "v 2.4.0"
        self.versionLabel.sizeToFit()
        
        // self.skView?.addSubview(self.versionLabel)
    }
    
    func toggleButton(button: UIButton) {
        var buttonName: String?
        let tag = button.tag
        if (tag == 0) {
            DataManager.sharedInstance.setObjectForKey(value: "eyes" as AnyObject?, key: "emitter_origin")
            self.stopAllActions()
            buttonName = "eyes"
            /*
            if (self.origin == .Eyes) {
                self.origin = .None
                self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
                return
            }
             */
            self.origin = .Eyes
            self.eyesToggleButton.setImage(UIImage(named: "eye_on_button"), for: .normal)
            self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
            self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
        } else if (tag == 1) {
            DataManager.sharedInstance.setObjectForKey(value: "mouth" as AnyObject?, key: "emitter_origin")
            self.stopAllActions()
            buttonName = "mouth"
            /*
            if (self.origin == .Mouth) {
                self.origin = .None
                self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
                return
            }
             */
            self.origin = .Mouth
            self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
            self.mouthToggleButton.setImage(UIImage(named: "mouth_on_button"), for: .normal)
            self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
        } else if (tag == 2) {
            DataManager.sharedInstance.setObjectForKey(value: "ears" as AnyObject?, key: "emitter_origin")
            self.stopAllActions()
            buttonName = "ears"
            /*
            if (self.origin == .Ears) {
                self.origin = .None
                self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
                return
            }
             */
            self.origin = .Ears
            self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
            self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
            self.earsToggleButton.setImage(UIImage(named: "ear_on_button"), for: .normal)
        } else if (tag == 3) {
            self.stopAllActions()
            if (!self.prepare) {
                if (self.recording) {
                    buttonName = "stop"
                    self.immediateStopRecording()
                    // self.stopRecording()
                    // self.recordButton.setImage(UIImage(named: "start_record_button"), for: .normal)
                } else {
                    buttonName = "record"
                    AdapterHTTPService.sharedInstance.startGame()
                    self.startRecording()
                    self.recordButton.setImage(UIImage(named: "stop_record_button"), for: .normal)
                }
            }
        } else {
            buttonName = "switch_camera"
            self.frontCamera = !self.frontCamera
            self.updateCameraSelection()
        }
        
        if let label = buttonName {
            AdapterGoogleAnalytics.sharedInstance.sendGoogleAnalyticsEventTracking(category: .Button, action: .Clicked, label: label)
        }
    }
    
    func stopAllActions() {
        DispatchQueue.main.async {
            self.scene?.removeAllChildren()
            if (self.scene?.children.count)! > 0 {
                for child in (self.scene?.children)! {
                    print("remove child: \(child.name)")
                    child.removeFromParent()
                }
            }
        }
        
        if (self.iceFrames.count > 0) {
            if (self.iceFrames[0].isDescendant(of: self.overlay)) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[0].alpha = 1.0
                    self.iceFrames[0].alpha = 0.0
                }, completion: { completed in
                    self.iceFrames[0].removeFromSuperview()
                })
            }
        }
        
        self.stopBackgroundMusic()
    }
    
    // MARK: - Camera Settings
    
    func cleanupVideoProcessing() {
        if ((self.videoDataOutput) != nil) {
           self.session?.removeOutput(self.videoDataOutput)
        }
        self.videoDataOutput = nil
    }
    
    func setupVideoProcessing() {
        self.videoDataOutput = AVCaptureVideoDataOutput()
        let rgbOutputSettings: Dictionary<AnyHashable, Any> = [
            "\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA
        ]
        self.videoDataOutput?.videoSettings = rgbOutputSettings
        
        if (!(self.session?.canAddOutput(self.videoDataOutput))!) {
            self.cleanupVideoProcessing()
            return
        }
        
        self.videoDataOutput?.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput?.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
        
        self.session?.addOutput(self.videoDataOutput)
    }
    
    func setupCameraPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.backgroundColor = UIColor.clear.cgColor
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let rootLayer: CALayer = self.placeHolder.layer
        rootLayer.masksToBounds = true
        self.previewLayer?.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer!)
    }
    
    func updateCameraSelection() {
        self.session?.beginConfiguration()
        
        // Remove old inputs
        let oldInputs = self.session?.inputs
        for oldInput in oldInputs! {
            self.session?.removeInput(oldInput as! AVCaptureInput)
        }
        
        let desiredPosition = self.frontCamera ? AVCaptureDevicePosition.front : AVCaptureDevicePosition.back
        let input = self.cameraForPosition(desiredPosition: desiredPosition)
        
        if (input == nil) {
            for oldInput in oldInputs! {
                self.session?.addInput(oldInput as! AVCaptureInput)
            }    
        } else {
            self.session?.addInput(input!)
        }
        
        self.session?.commitConfiguration()
        
        self.setup = false
    }
    
    func cameraForPosition(desiredPosition: AVCaptureDevicePosition) -> AVCaptureDeviceInput? {
        for (_, device) in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).enumerated() {
            if ((device as! AVCaptureDevice).position == desiredPosition) {
                var finalFormat = AVCaptureDeviceFormat()
                var maxFps: Double = 0
                var minFps: Double = 99
                /*
                let ranges = (device as! AVCaptureDevice).activeFormat.videoSupportedFrameRateRanges as! [AVFrameRateRange]
                for range in ranges {
                    if (range.maxFrameRate >= maxFps) {
                        maxFps = range.maxFrameRate
                    }
                }
                if maxFps != 0 {
                    print("maxFps: \(maxFps)")
                    let timeValue = Int64(1200.0 / maxFps)
                    let timeScale: Int32 = 1200
                    try! (device as! AVCaptureDevice).lockForConfiguration()
                    (device as! AVCaptureDevice).activeFormat = (device as! AVCaptureDevice).activeFormat
                    (device as! AVCaptureDevice).activeVideoMinFrameDuration = CMTimeMake(timeValue, timeScale)
                    (device as! AVCaptureDevice).activeVideoMaxFrameDuration = CMTimeMake(timeValue, timeScale)
                    (device as! AVCaptureDevice).unlockForConfiguration()
                }
                 */
                for format in (device as! AVCaptureDevice).formats {
                    let ranges = (format as! AVCaptureDeviceFormat).videoSupportedFrameRateRanges as! [AVFrameRateRange]
                    let frameRates = ranges[0]
                    /*
                    if (frameRates.maxFrameRate >= maxFps  && frameRates.maxFrameRate <= 240) {
                        maxFps = frameRates.maxFrameRate
                        finalFormat = format as! AVCaptureDeviceFormat
                    }
                     */
                    if (frameRates.minFrameRate <= minFps) {
                        minFps = frameRates.minFrameRate
                        finalFormat = format as! AVCaptureDeviceFormat
                    }
                }
                if minFps != 99 {
                    print("maxFps: \(minFps)")
                    let timeValue = Int64(1200.0 / minFps)
                    let timeScale: Int32 = 1200
                    try! (device as! AVCaptureDevice).lockForConfiguration()
                    (device as! AVCaptureDevice).activeFormat = finalFormat
                    (device as! AVCaptureDevice).activeVideoMinFrameDuration = CMTimeMake(timeValue, timeScale)
                    (device as! AVCaptureDevice).activeVideoMaxFrameDuration = CMTimeMake(timeValue, timeScale)
                    (device as! AVCaptureDevice).unlockForConfiguration()
                }
                let input = try! AVCaptureDeviceInput(device: (device as! AVCaptureDevice))
                if ((self.session?.canAddInput(input))!) {
                    return input
                }
            }
        }
        return nil
    }
    
    func playBackgroundMusic(filename: String) {
        
        var resourceName = "beam"
        
        let randomUInt: UInt32 = arc4random_uniform(2)
        let random: Int = Int(randomUInt)
        if (random == 0) {
            resourceName = "sfx"
        }
        
        //The location of the file and its type
        let url = Bundle.main.url(forResource: resourceName, withExtension: "wav")
        
        //Returns an error if it can't find the file name
        if (url == nil) {
            return
        }
        
        var error: NSError? = nil
        
        //Assigns the actual music to the music player
        self.backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: url!)
        
        //Error if it failed to create the music player
        if backgroundMusicPlayer == nil {
            return
        }
        
        //A negative means it loops forever
        self.backgroundMusicPlayer?.stop()
        self.backgroundMusicPlayer?.numberOfLoops = -1
        self.backgroundMusicPlayer?.prepareToPlay()
        self.backgroundMusicPlayer?.play()
        
        self.isSoundPlaying = true
    }
    
    func stopBackgroundMusic() {
        self.backgroundMusicPlayer?.stop()
        self.backgroundMusicPlayer = nil
        self.isSoundPlaying = false
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .fullScreen
        /*
        if appDelegate.isiPad {
        } else {
         
        }
         */
    }
    
}

extension GameViewController: AVAudioSessionDelegate {
}

extension GameViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.viewDidAppear(true)
    }
    
}
