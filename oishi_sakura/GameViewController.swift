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
    
    private var didCancel: Bool = false
    private var showAlert: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
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
        
        self.placeHolder.frame = self.view.frame
        self.overlay.frame = self.view.frame
        
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
            GMVDetectorFaceMinSize: 0.3,
            GMVDetectorFaceTrackingEnabled: true,
            GMVDetectorFaceMode: GMVDetectorFaceModeOption.fastMode.rawValue,
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue
        ]
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        // game scene
        self.skView = SKView(frame: self.view.frame)
        self.skView?.backgroundColor = UIColor.clear
        
        self.scene = GameScene(size: UIScreen.main.bounds.size)
        self.scene?.scaleMode = .aspectFill
        self.scene?.backgroundColor = UIColor.clear
        self.skView?.presentScene(self.scene)
       
        self.skView?.ignoresSiblingOrder = true
        
        self.skView?.showsFPS = true
        self.skView?.showsNodeCount = true
        
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
        
        // overlay window
        self.overlayWindow = UIWindow(frame: (self.view.window?.frame)!)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                self.scene?.noPointDetected()
                self.removeCheeks()
                return
            }
                
            if (self.origin == .None) {
                if let soundNode = self.scene?.childNode(withName: "sound") {
                    soundNode.removeFromParent()
                }
                self.scene?.noPointDetected()
                self.removeCheeks()
                return
            }
            
            // Display detected features in overlay.
            for face in faces {
                
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
                                self.scene?.earsPointDetected(face: face, lpos: lpoint, rpos: rpoint, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
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
                                
                                self.scene?.eyesPointDetected(face: face, lpos: lpoint, rpos: rpoint, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                            }
                        }
                    
                        // Cheeks
                        if (face.hasLeftCheekPosition && face.hasRightCheekPosition) {
                            // TODO: - move cheek image view to skspritenode in game scene
                            var editedLeftCheekPosition = face.leftCheekPosition
                            editedLeftCheekPosition.y -= (0.065 * face.bounds.size.height)
                            
                            var editedRightCheekPosition = face.rightCheekPosition
                            editedRightCheekPosition.y -= (0.065 * face.bounds.size.height)
                            
                            let lpoint = self.scaledPoint(point: editedLeftCheekPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                            let rpoint = self.scaledPoint(point: editedRightCheekPosition, xScale: self.xScale, yScale: self.yScale, offset: self.videoBox.origin)
                            
                            if (!self.addedCheeks) {
                                
                                /*
                                if (self.recording) {
                                    if let round = KeychainWrapper.standard.integer(forKey: "round") {
                                        if (round == 1) {
                                            self.leftCheekImageView.image = UIImage(named: "cheek_1_left")
                                            self.rightCheekImageView.image = UIImage(named: "cheek_1_right")   
                                        } else {
                                            self.leftCheekImageView.image = UIImage(named: "cheek_\(index)")
                                            self.rightCheekImageView.image = UIImage(named: "cheek_\(index)")
                                        }
                                    } else {
                                        KeychainWrapper.standard.set(1, forKey: "round")
                                        self.leftCheekImageView.image = UIImage(named: "cheek_1_left")
                                        self.rightCheekImageView.image = UIImage(named: "cheek_1_right")
                                    }
                                } else {*/
                                var randomNum: UInt32 = arc4random_uniform(4)
                                var index: Int = Int(randomNum) + 1
                                
                                if (index == 1) {
                                    self.leftCheekImageView.image = UIImage(named: "cheek_1_left")
                                    self.rightCheekImageView.image = UIImage(named: "cheek_1_right")
                                } else {
                                    self.leftCheekImageView.image = UIImage(named: "cheek_\(index)")
                                    self.rightCheekImageView.image = UIImage(named: "cheek_\(index)")
                                }
                                // }
                                
                                randomNum = arc4random_uniform(2)
                                index = Int(randomNum)
                                if (index == 0) {
                                    self.overlay.addSubview(self.iceFrames[0])
                                    UIView.animate(withDuration: 0.25, animations: {
                                        self.iceFrames[0].alpha = 0.0
                                        self.iceFrames[0].alpha = 1.0
                                    })
                                }
                                
                                self.leftCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.75, h: face.bounds.size.width * 0.75)
                                self.rightCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.75, h: face.bounds.size.width * 0.75)
                                
                                self.leftCheekImageView.center = lpoint
                                self.rightCheekImageView.center = rpoint
                                
                                self.leftCheekImageView.layer.zPosition = 1000
                                self.rightCheekImageView.layer.zPosition = 1000
                                
                                self.overlay.addSubview(self.leftCheekImageView)
                                self.overlay.addSubview(self.rightCheekImageView)
                                
                                self.addedCheeks = true
                            } else {
                                self.leftCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.7, h: face.bounds.size.width * 0.7)
                                self.rightCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.7, h: face.bounds.size.width * 0.7)
                                
                                self.leftCheekImageView.center = lpoint
                                self.rightCheekImageView.center = rpoint
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
        
        UIView.animate(withDuration: 0.25, animations: {
            self.iceFrames[0].alpha = 1.0
            self.iceFrames[0].alpha = 0.0
        }, completion: { completed in
            self.iceFrames[0].removeFromSuperview()
        })
        
        self.prepare = true
        
        self.removeCheeks()
        self.scene?.removeAllChildren()
        self.scene?.resetEmitterNodes()
        
        self.swapCameraButton.isHidden = true
        self.eyesToggleButton.isHidden = true
        self.mouthToggleButton.isHidden = true
        self.earsToggleButton.isHidden = true
        
        recorder.startRecording(withMicrophoneEnabled: true, handler: { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
            self.iceFrames[0].removeFromSuperview()
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
                
                if let round = KeychainWrapper.standard.integer(forKey: "round") {
                    KeychainWrapper.standard.set(round + 1, forKey: "round")
                }
                
                self.scene?.removeAllChildren()
                self.scene?.resetEmitterNodes()
                
                self.origin = .None
                
                preview.previewControllerDelegate = self
                self.present(preview, animated: true, completion: { completed in
                    self.endSceneImageView.removeFromSuperview()
                })
                self.recording = false
            }
        })
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        
        DispatchQueue.main.async {
            
            if let node = self.scene?.childNode(withName: "sound") {
                node.removeFromParent()
            }
            
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
                if (self.didCancel) {
                    previewController.dismiss(animated: true, completion: { _ in
                        self.didCancel = false
                    })
                    if let soundNode = self.scene?.childNode(withName: "sound") {
                        soundNode.removeFromParent()
                    }
                } else {
                    self.didCancel = true
                    let popup = PopupView(frame: self.view.frame)
                    popup.initCancelSaveVideo()
                    previewController.view.addSubview(popup)
                    if let soundNode = self.scene?.childNode(withName: "sound") {
                        soundNode.removeFromParent()
                    }
                }
            }
            
        }
    }
    
    func addDownloadingView() {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor.black
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = view.center
        activity.startAnimating()
        
        let label = UILabel(frame: CGRect.init(x: 0.0, y: view.center.y + 40.0, width: view.frame.size.width, height: 50.0))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0, weight: 0.85)
        label.text = "Processing video ..."
        
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
        self.timerCounter = 0.5
        for index in 0...2 {
            self.iceFrames[index].removeFromSuperview()
        }
    }
    
    func changeState() {
        self.timerCounter += 0.5
        print("time @ \(self.timerCounter)")
        if (self.timerCounter == 0.0) {
            if (self.timerCounter == 0.0) {
                for index in 0...2 {
                    self.iceFrames[index].removeFromSuperview()
                    self.iceFrames[index].alpha = 0.0
                }
            }
            // start recording -> 2.0 s
            // white sakura, pink light ray, cheek 1, no ice frame
            print("start recording")
        } else if (self.timerCounter >= 2.0 && self.timerCounter < 3.5) {
            // 1.5s
            // pink sakura, blue light ray, cheek 2, ice frame level 1
            print("change to state 1")
            if (self.timerCounter == 2.0) {
                self.currentState += 1
                self.scene?.changeLightEmitterNode(pink: false)
                self.overlay.addSubview(self.iceFrames[0])
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[0].alpha = 0.0
                    self.iceFrames[0].alpha = 1.0
                })
            }
        } else if (self.timerCounter == 3.5 && self.timerCounter < 5.0) {
           // 1.5s
            // pink sakura, blue light ray, cheek 2, ice frame level 2
            print("change to state 2")
            if (self.timerCounter == 3.5) {
                self.overlay.addSubview(self.iceFrames[1])
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[1].alpha = 0.0
                    self.iceFrames[1].alpha = 1.0
                })
            }
        } else if (self.timerCounter == 5.0 && self.timerCounter < 6.5) {
           // 1.5s
            // pink sakura, blue light ray, cheek 2, ice frame level 3
            print("change to state 3")
            if (self.timerCounter == 5.0) {
                self.overlay.addSubview(self.iceFrames[2])
                UIView.animate(withDuration: 0.25, animations: {
                    self.iceFrames[2].alpha = 0.0
                    self.iceFrames[2].alpha = 1.0
                })
            }
        } else if (self.timerCounter == 6.5 && self.timerCounter < 7.0) {
            // 0.5s
            // show end screen
            print("show end screen")
            if (self.timerCounter == 6.5) {
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
        } else if (self.timerCounter == 8.0) {
            // stop recording
            print("stop recording")
            self.scene?.changeLightEmitterNode(pink: true)
            self.stopTimer()
        }
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
        self.versionLabel.text = "v 2.3.1"
        self.versionLabel.sizeToFit()
        
        self.skView?.addSubview(self.versionLabel)
    }
    
    func toggleButton(button: UIButton) {
        let tag = button.tag
        if (tag == 0) {
            self.stopAllActions()
            if (self.origin == .Eyes) {
                self.origin = .None
                self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
                return
            }
            self.origin = .Eyes
            self.eyesToggleButton.setImage(UIImage(named: "eye_on_button"), for: .normal)
            self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
            self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
        } else if (tag == 1) {
            self.stopAllActions()
            if (self.origin == .Mouth) {
                self.origin = .None
                self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
                return
            }
            self.origin = .Mouth
            self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
            self.mouthToggleButton.setImage(UIImage(named: "mouth_on_button"), for: .normal)
            self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
        } else if (tag == 2) {
            self.stopAllActions()
            if (self.origin == .Ears) {
                self.origin = .None
                self.earsToggleButton.setImage(UIImage(named: "ear_button"), for: .normal)
                return
            }
            self.origin = .Ears
            self.eyesToggleButton.setImage(UIImage(named: "eye_button"), for: .normal)
            self.mouthToggleButton.setImage(UIImage(named: "mouth_button"), for: .normal)
            self.earsToggleButton.setImage(UIImage(named: "ear_on_button"), for: .normal)
        } else if (tag == 3) {
            if (self.recording) {
                self.stopRecording()
                self.recordButton.setImage(UIImage(named: "start_record_button"), for: .normal)
            } else {
                self.startRecording()
                self.recordButton.setImage(UIImage(named: "stop_record_button"), for: .normal)
            }
        } else {
            self.frontCamera = !self.frontCamera
            self.updateCameraSelection()
        }
    }
    
    func stopAllActions() {
        self.scene?.removeAllChildren()
        UIView.animate(withDuration: 0.25, animations: {
            self.iceFrames[0].alpha = 1.0
            self.iceFrames[0].alpha = 0.0
        }, completion: { completed in
            self.iceFrames[0].removeFromSuperview()
        })
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
                    print("frameRates: \(frameRates.maxFrameRate)")
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
                    print("maxFps: \(maxFps)")
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
    
}
