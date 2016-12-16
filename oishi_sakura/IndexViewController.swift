//
//  IndexViewController.swift
//  oishi
//
//  Created by warinporn khantithamaporn on 8/29/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import UIKit
import SystemConfiguration

class IndexViewController: UIViewController {
    
    var backgroundImageView: UIImageView = UIImageView()
    var button: UIButton = UIButton()
    
    var timer = Timer()
    var counter: Int = 0
    var isLoadedData: Bool = false
    
    // MARK: - frame
    private var realFrame: CGRect = CGRect.zero
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(IndexViewController.skipIndex), userInfo: nil, repeats: false)
    }
    
    func skipIndex() {
        // TODO: - goto tutorial or mylist
        ControllerManager.sharedInstance.presentMainController()
    }
    
}
