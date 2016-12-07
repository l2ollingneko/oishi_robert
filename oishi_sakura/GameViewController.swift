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

enum SakuraOrigin {
    case Mouth, Eyes, Ears, None
}

class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, RPPreviewViewControllerDelegate {
    
    // MARK: - UI elements
    @IBOutlet weak var placeHolder: UIView!
    @IBOutlet weak var overlay: UIView!
    
    var swapCameraButton: UIButton = UIButton()
    var eyesToggleButton: UIButton = UIButton()
    var mouthToggleButton: UIButton = UIButton()
    var earsToggleButton: UIButton = UIButton()
    var recordButton: UIButton = UIButton()
    
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
    
    // MARK: - sakura position
    
    var origin: SakuraOrigin = .None
    
    // MARK: - face
    
    private var leftCheekImageView: UIImageView = UIImageView()
    private var rightCheekImageView: UIImageView = UIImageView()
    private var addedCheeks: Bool = false
    
    // MARK: - camera
    
    private var frontCamera: Bool = true
    
    // MARK: - testing
    
    private var versionLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // video
        self.session = AVCaptureSession()
        self.session?.sessionPreset = AVCaptureSessionPresetHigh
        self.updateCameraSelection()
        
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        
        self.setupVideoProcessing()
        self.setupCameraPreview()
        
        // gmvdetector
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorFaceMinSize: 0.3,
            GMVDetectorFaceTrackingEnabled: true,
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
        
        self.leftCheekImageView.image = UIImage(named: "cheek")
        self.rightCheekImageView.image = UIImage(named: "cheek")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.previewLayer?.frame = self.view.layer.bounds
        self.previewLayer?.position = CGPoint(x: (self.previewLayer?.frame)!.midX, y: (self.previewLayer?.frame)!.midY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
        self.initUIElements()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.stopRunning()
    }
    
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
        let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: UIScreen.main.bounds.size.height - (point.y * yScale + offset.y))
        return resultPoint
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer)
        // let image = UIImage(cgImage: GMVUtility.sampleBufferTo32RGBA(sampleBuffer).cgImage!, scale: 1.0, orientation: UIImageOrientation.left)
        
        let orientation = GMVUtility.imageOrientation(from: UIDevice.current.orientation, with: AVCaptureDevicePosition.front, defaultDeviceOrientation: .unknown)
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorImageOrientation: orientation.rawValue
        ]
        let faces = self.faceDetector?.features(in: image, options: options) as! [GMVFaceFeature]
        
        let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false)
        let parentFrameSize = self.previewLayer?.frame.size
        
        let cameraRatio = clap.size.height / clap.size.width
        let viewRatio = (parentFrameSize?.width)! / (parentFrameSize?.height)!
        var xScale: CGFloat = 1
        var yScale: CGFloat = 1
        var videoBox = CGRect.zero
       
        videoBox.size.width = (parentFrameSize?.width)!
        videoBox.size.height = clap.size.width * ((parentFrameSize?.width)! / clap.size.height)
        videoBox.origin.x = (videoBox.size.width - (parentFrameSize?.width)!) / 2
        videoBox.origin.y = ((parentFrameSize?.height)! - videoBox.size.height) / 2

        xScale = videoBox.size.width / clap.size.height;
        yScale = videoBox.size.height / clap.size.width;
        
        /*
        if (viewRatio > cameraRatio) {
            videoBox.size.width = (parentFrameSize?.height)! * clap.size.width / clap.size.height
            videoBox.size.height = (parentFrameSize?.height)!
            videoBox.origin.x = ((parentFrameSize?.width)! - videoBox.size.width) / 2
            videoBox.origin.y = (videoBox.size.height - (parentFrameSize?.height)!) / 2

            xScale = videoBox.size.width / clap.size.width
            yScale = videoBox.size.height / clap.size.height
        } else {
            videoBox.size.width = (parentFrameSize?.width)!
            videoBox.size.height = clap.size.width * ((parentFrameSize?.width)! / clap.size.height)
            videoBox.origin.x = (videoBox.size.width - (parentFrameSize?.width)!) / 2
            videoBox.origin.y = ((parentFrameSize?.height)! - videoBox.size.height) / 2

            xScale = videoBox.size.width / clap.size.height;
            yScale = videoBox.size.height / clap.size.width;
        }
         */
        
        DispatchQueue.main.sync {
            // Remove previously added feature views.
            /*
            for featureView in self.overlayView.subviews {
                featureView.removeFromSuperview()
            }
            */
            
            if (faces.count == 0) {
                self.scene?.noPointDetected()
                self.removeCheeks()
            }
            
            if (self.origin == .None) {
                self.scene?.noPointDetected()
                self.removeCheeks()
            }
            
            // Display detected features in overlay.
            for face in faces {
                // let faceRect = self.scaledRect(rect: face.bounds, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                // DrawingUtility.addRectangle(faceRect, to: self.overlayView, with: UIColor.red)
                
                // Mouth
                if (self.origin == .Mouth) {
                    if (face.hasMouthPosition == true) {
                        let point = self.frontCamera ? self.scaledPointForScene(point: face.mouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin) : self.scaledPoint(point: face.mouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        self.scene?.pointDetected(atPoint: point, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                    }
                }
                
                // Ears
                if (self.origin == .Ears) {
                    if (face.hasLeftEarPosition && face.hasRightEarPosition) {
                        let lpoint = self.frontCamera ? self.scaledPointForScene(point: face.leftEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin) : self.scaledPoint(point: face.leftEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        let rpoint = self.frontCamera ? self.scaledPointForScene(point: face.rightEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin) : self.scaledPoint(point: face.rightEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        self.scene?.earsPointDetected(lpos: lpoint, rpos: rpoint, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                    }
                }
                
                // Eyes
                if (self.origin == .Eyes) {
                    if (face.hasLeftEyePosition && face.hasRightEyePosition) {
                        let lpoint = self.frontCamera ? self.scaledPointForScene(point: face.leftEyePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin) : self.scaledPoint(point: face.leftEyePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        let rpoint = self.frontCamera ? self.scaledPointForScene(point: face.rightEyePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin) : self.scaledPoint(point: face.rightEyePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        self.scene?.eyesPointDetected(lpos: lpoint, rpos: rpoint, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                    }
                }
                
                // Cheeks
                if (self.origin != .None) {
                    if (face.hasLeftCheekPosition && face.hasRightCheekPosition) {
                        let lpoint = self.scaledPoint(point: face.leftCheekPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        let rpoint = self.scaledPoint(point: face.rightCheekPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                        
                        if (!self.addedCheeks) {
                            self.leftCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.5, h: face.bounds.size.width * 0.5)
                            self.rightCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.5, h: face.bounds.size.width * 0.5)
                            
                            self.leftCheekImageView.center = lpoint
                            self.rightCheekImageView.center = rpoint
                            
                            self.leftCheekImageView.layer.zPosition = 1000
                            self.rightCheekImageView.layer.zPosition = 1000
                            
                            self.overlay.addSubview(self.leftCheekImageView)
                            self.overlay.addSubview(self.rightCheekImageView)
                            /*
                            self.skView?.addSubview(self.leftCheekImageView)
                            self.skView?.addSubview(self.rightCheekImageView)
                             */
                            self.addedCheeks = true
                        } else {
                            self.leftCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.5, h: face.bounds.size.width * 0.5)
                            self.rightCheekImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: face.bounds.size.width * 0.5, h: face.bounds.size.width * 0.5)
                            self.leftCheekImageView.center = lpoint
                            self.rightCheekImageView.center = rpoint
                        }
                    }
                }
            }
        }
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
        let rgbOutputSettings: Dictionary<AnyHashable, Any> = ["\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA]
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
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
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
    }
    
    func cameraForPosition(desiredPosition: AVCaptureDevicePosition) -> AVCaptureDeviceInput? {
        for (_, device) in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).enumerated() {
            if ((device as! AVCaptureDevice).position == desiredPosition) {
                let input = try! AVCaptureDeviceInput(device: (device as! AVCaptureDevice))
                if ((self.session?.canAddInput(input))!) {
                    return input
                }
            }
        }
        /*
        if #available(iOS 10.0, *) {
            for (_, device) in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).enumerated() {
                if ((device as! AVCaptureDevice).position == desiredPosition) {
                    let input = try! AVCaptureDeviceInput(device: (device as! AVCaptureDevice))
                    if ((self.session?.canAddInput(input))!) {
                        return input
                    }
                }
            }
            /*
            if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
                if (device.position == desiredPosition) {
                    let input = try! AVCaptureDeviceInput(device: device)
                    if ((self.session?.canAddInput(input))!) {
                        return input
                    }
                }    
            }
     */
        } else {
            // Fallback on earlier versions
            for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                if ((device as! AVCaptureDevice).position == desiredPosition) {
                    let input = try! AVCaptureDeviceInput(device: (device as! AVCaptureDevice))
                    if ((self.session?.canAddInput(input))!) {
                        return input
                    }
                }
            }
        }
         */
        return nil
    }
    
    // MARK: - cheek detected
    
    func cheeksDetected(faceRect: CGRect, leftCheekPoint: CGPoint, rightCheekPoint: CGPoint) {
        self.leftCheekImageView.center = leftCheekPoint
        self.rightCheekImageView.center = rightCheekPoint
    }
    
    func removeCheeks() {
        if (self.addedCheeks) {
            self.leftCheekImageView.removeFromSuperview()
            self.rightCheekImageView.removeFromSuperview()
            self.addedCheeks = false
        }
    }
    
    // MARK: - ReplayKit
    
    func startRecording() {
        let recorder = RPScreenRecorder.shared()
        
        /*
        let screenRecorder = ASScreenRecorder.sharedInstance()
        if (!(screenRecorder?.isRecording)!) {
            screenRecorder?.startRecording()
        }
        */
        
        self.swapCameraButton.isHidden = true
        self.eyesToggleButton.isHidden = true
        self.mouthToggleButton.isHidden = true
        self.earsToggleButton.isHidden = true
        
        recorder.startRecording(withMicrophoneEnabled: true, handler: { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.recording = true
                print("recording video")
            }
        })
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.shared()
        
        /*
        let screenRecorder = ASScreenRecorder.sharedInstance()
        if ((screenRecorder?.isRecording)!) {
            screenRecorder?.stopRecording(completion: {
            })
        }
        */
        
        self.swapCameraButton.isHidden = false
        self.eyesToggleButton.isHidden = false
        self.mouthToggleButton.isHidden = false
        self.earsToggleButton.isHidden = false
        
        recorder.stopRecording(handler: { (preview, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let preview = preview {
                // self.placeHolder.removeFromSuperview()
                // self.overlayView.removeFromSuperview()
                preview.previewControllerDelegate = self
                self.present(preview, animated: true)
                self.recording = false
            }
        })
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        for type in activityTypes {
            print("activiyType: \(type)")
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
        
        // self.skView?.addSubview(self.swapCameraButton)
        self.skView?.addSubview(self.eyesToggleButton)
        self.skView?.addSubview(self.mouthToggleButton)
        self.skView?.addSubview(self.earsToggleButton)
        self.skView?.addSubview(self.recordButton)
        
        self.versionLabel.frame.origin = CGPoint(x: 10.0, y: 0.0)
        self.versionLabel.font = UIFont.systemFont(ofSize: 30.0)
        self.versionLabel.textColor = UIColor.white
        self.versionLabel.text = "v 2.0.1"
        self.versionLabel.sizeToFit()
        
        self.skView?.addSubview(self.versionLabel)
    }
    
    func toggleButton(button: UIButton) {
        let tag = button.tag
        if (tag == 0) {
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
    
}
