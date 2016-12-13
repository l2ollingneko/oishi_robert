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

class ControllerManager {
    
    static let sharedInstance = ControllerManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func mainController() -> GameViewController {
        // return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        return GameViewController(nibName: "GameViewController", bundle: nil)
    }
    
    func presentMainController() {
        self.appDelegate.window?.rootViewController = self.mainController()
        self.appDelegate.window?.makeKeyAndVisible()
    }
    
    func previewController(rp: RPPreviewViewController) -> PreviewVideoViewController {
        let controller = PreviewVideoViewController(nibName: "PreviewVideoViewController", bundle: nil)
        controller.preview = rp
        return controller
    }
    
    func presentPreviewVideoController(rp: RPPreviewViewController) {
        self.appDelegate.window?.rootViewController = self.previewController(rp: rp)
        self.appDelegate.window?.makeKeyAndVisible()
    }

}
