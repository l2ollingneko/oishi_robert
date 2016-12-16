//
//  IndexViewController.swift
//  oishi
//
//  Created by warinporn khantithamaporn on 8/29/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import UIKit
import SystemConfiguration
import AVFoundation
import UserNotifications

class IndexViewController: UIViewController {
    
    var backgroundImageView: UIImageView = UIImageView()
    var button: UIButton = UIButton()
    
    var timer = Timer()
    var counter: Int = 0
    var isLoadedData: Bool = false
    
    // MARK: - frame
    private var realFrame: CGRect = CGRect.zero
    
    private var skipable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isiPad {
            self.realFrame = CGRect.init(x: 0.0, y: 0.0, width: 540.0, height: 960.0)
        } else {
            self.realFrame = self.view.frame
        }
        
        self.view.backgroundColor = UIColor.clear
        self.backgroundImageView.backgroundColor = UIColor.clear
        
        self.view.clipsToBounds = true
        self.backgroundImageView.clipsToBounds = true

        // Do any additional setup after loading the view.
        self.backgroundImageView.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        self.backgroundImageView.image = UIImage(named: "index")
        
        self.button.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        // self.button.addTarget(self, action: #selector(IndexViewController.skipIndex), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.button)
       
        AdapterHTTPService.sharedInstance.openApp()
        
    }
    
    override func viewWillLayoutSubviews() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isiPad {
            self.view.frame = CGRect.init(x: 114.0, y: 32.0, width: 540.0, height: 960.0)
        }
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
        
        AdapterGoogleAnalytics.sharedInstance.sendGoogleAnalyticsEventTracking(category: .Page, action: .Opened, label: "splash_page")
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(IndexViewController.skipIndex), userInfo: nil, repeats: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func skipIndex() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == AVAuthorizationStatus.denied) {
            self.skipable = false
            let popup = PopupView(frame: self.realFrame)
            popup.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            popup.backgroundImageView.image = UIImage(named: "change_privacy")
            popup.layer.zPosition = 10000
            self.view.addSubview(popup)
        } else {
            ControllerManager.sharedInstance.presentMainController()
        }
        
        /*
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if (status == AVAuthorizationStatus.denied) {
                self.skipable = false
        } else if (status == AVAuthorizationStatus.notDetermined) {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
                if (!granted) {
                    self.skipable = false
                    let popup = PopupView(frame: self.realFrame)
                    popup.backgroundColor = UIColor.black.withAlphaComponent(0.65)
                    popup.backgroundImageView.image = UIImage(named: "change_privacy")
                    popup.layer.zPosition = 10000
                    self.view.addSubview(popup)
                    self.skipIndex()
                } else {
                    // ControllerManager.sharedInstance.presentMainController()
                    // Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(IndexViewController.skipIndex), userInfo: nil, repeats: false)
                    self.skipable = true
                    Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(IndexViewController.skipIndex), userInfo: nil, repeats: false)
                }
            })
        } else if (status == AVAuthorizationStatus.restricted) {
            self.skipable = false
        } else if (status == AVAuthorizationStatus.authorized) {
            ControllerManager.sharedInstance.presentMainController()
            // Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(IndexViewController.skipIndex), userInfo: nil, repeats: false)
        }
        
        if (!self.skipable) {
            let popup = PopupView(frame: self.realFrame)
            popup.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            popup.backgroundImageView.image = UIImage(named: "change_privacy")
            popup.layer.zPosition = 10000
            self.view.addSubview(popup)
        }
        
        // TODO: - goto tutorial or mylist
        if (!self.skipable) {
            // ControllerManager.sharedInstance.presentMainController()
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(IndexViewController.skipIndex), userInfo: nil, repeats: false)
        }
         */
    }
    
}
