//
//  OishiViewController.swift
//  oishi_sakura
//
//  Created by Witsarut Suwanich on 12/6/16.
//  Copyright © 2016 Plaping Co., Ltd. All rights reserved.
//

import UIKit
import GoogleMobileVision
import GoogleMVDataOutput

class OishiViewController: UIViewController, FaceTrackerDatasource, GMVMultiDataOutputDelegate {
    
    // MARK: - UI elements
    @IBOutlet weak var placeHolder: UIView!
    @IBOutlet weak var overlay: UIView!

    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var dataOutput: GMVDataOutput?
    
    // MARK: - camera
    private var frontCamera: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.session = AVCaptureSession()
        self.session?.sessionPreset = AVCaptureSessionPresetMedium
        self.updateCameraSelection()
        
        self.setupGMVDataOutput()
        
        self.setupCameraPreview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.previewLayer?.frame = self.view.layer.bounds
        self.previewLayer?.position = CGPoint(x: (self.previewLayer?.frame)!.midX, y: (self.previewLayer?.frame)!.midY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.stopRunning()
    }
    
    // MARK: - Facetracker
    
    func overlayView() -> UIView! {
        return self.overlay
    }
    
    func xScale() -> CGFloat {
        return (self.dataOutput?.xScale)!
    }
    
    func yScale() -> CGFloat {
        return (self.dataOutput?.yScale)!
    }
    
    func offset() -> CGPoint {
        return (self.dataOutput?.offset)!
    }
    
    // MARK: - GMVDataOutputDelegate
    
    func dataOutput(_ dataOutput: GMVDataOutput!, trackerFor feature: GMVFeature!) -> GMVOutputTrackerDelegate! {
        let tracker = FaceTracker()
        tracker.delegate = self
        return tracker
    }

    // MARK: - GMV Pipeline Setup
    
    func setupGMVDataOutput() {
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorFaceTrackingEnabled: true,
            GMVDetectorFaceMode: GMVDetectorFaceModeOption.fastMode.rawValue,
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue,
            GMVDetectorFaceClassificationType: GMVDetectorFaceClassification.all.rawValue,
            GMVDetectorFaceMinSize: self.frontCamera ? 0.35 : 0.15
        ]
        
        let detector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        if (self.frontCamera) {
            self.dataOutput = GMVLargestFaceFocusingDataOutput(detector: detector)
            let tracker = FaceTracker()
            tracker.delegate = self
            (self.dataOutput as! GMVLargestFaceFocusingDataOutput).trackerDelegate = tracker
        } else {
            self.dataOutput = GMVMultiDataOutput(detector: detector)
            (self.dataOutput as! GMVMultiDataOutput).multiDataDelegate = self
        }
        
        if (!(self.session?.canAddOutput(self.dataOutput))!) {
            self.cleanupGMVDataOutput()
            return
        }
        self.session?.addOutput(self.dataOutput)
    }
    
    func cleanupGMVDataOutput() {
        if (self.dataOutput != nil) {
            self.session?.removeOutput(self.dataOutput)
        }
        self.dataOutput?.cleanup()
        self.dataOutput = nil
    }

    // MARK: - camera setup
    
    func cleanCaptureSession() {
        self.session?.stopRunning()
        self.cleanupGMVDataOutput()
        self.session = nil
        self.previewLayer?.removeFromSuperlayer()
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
        return nil
    }
    
}
