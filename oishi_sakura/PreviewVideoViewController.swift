//
//  PreviewVideoViewController.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 12/9/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import UIKit
import ReplayKit

class PreviewVideoViewController: UIViewController {
    
    var preview: RPPreviewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.preview?.previewControllerDelegate = self
        self.present(preview!, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PreviewVideoViewController: RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    }
    
}
