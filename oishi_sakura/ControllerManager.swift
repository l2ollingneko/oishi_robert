//
//  ControllerManager.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 12/13/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import Foundation
import ReplayKit
import UIKit
import AVKit

class ControllerManager {
    
    static let sharedInstance = ControllerManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func indexController() -> IndexViewController {
        return IndexViewController(nibName: "IndexViewController", bundle: nil)
    }
    
    func presentIndexController() {
        self.appDelegate.window?.rootViewController = self.indexController()
        self.appDelegate.window?.makeKeyAndVisible()
    }
    
    func mainController() -> GameViewController {
        return GameViewController(nibName: "GameViewController", bundle: nil)
    }
    
    func presentMainController() {
        self.appDelegate.window?.rootViewController = self.mainController()
        self.appDelegate.window?.makeKeyAndVisible()
    }
    
    func previewController() -> PreviewVideoViewController {
        let controller = PreviewVideoViewController(nibName: "PreviewVideoViewController", bundle: nil)
        return controller
    }
    
    func presentPreviewVideoController() {
        self.appDelegate.window?.rootViewController = self.previewController()
        self.appDelegate.window?.makeKeyAndVisible()
    }
    
    func presentVideoPlayerController(controller: AVPlayerViewController) {
        self.appDelegate.window?.rootViewController = controller
        self.appDelegate.window?.makeKeyAndVisible()
        controller.player?.play()
    }
    
}
