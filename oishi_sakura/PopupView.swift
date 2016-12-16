//
//  PopupView.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 12/14/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import UIKit

protocol PopupViewDelegate {
    func popupClosed()
}

class PopupView: UIView {
    
    var backgroundImageView: UIImageView = UIImageView()
    
    // 996, 610, 160, 160
    var closeButton: UIButton = UIButton()
    var leftButton: UIButton = UIButton()
    var rightButton: UIButton = UIButton()
    
    var delegate: PopupViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = frame
        self.backgroundColor = UIColor.clear
        
        self.backgroundImageView.frame = frame
        self.backgroundImageView.image = UIImage(named: "popup_bg")
        self.backgroundImageView.layer.zPosition = 0
        self.backgroundImageView.isUserInteractionEnabled = true
        
        self.closeButton.frame = Adapter.calculatedRectFromRatio(x: 996.0, y: 610.0, w: 160.0, h: 160.0)
        self.closeButton.layer.zPosition = 1000
        self.closeButton.addTarget(self, action: #selector(PopupView.close(button:)), for: .touchUpInside)
        
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.closeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initCancelSaveVideo() {
        var popupImageView: UIImageView = UIImageView(frame: self.frame)
        
        popupImageView.image = UIImage(named: "no_video")
        popupImageView.layer.zPosition = 500
        
        self.addSubview(popupImageView)
        self.bringSubview(toFront: self.closeButton)
    }
    
    func close(button: UIButton) {
        print("close did tap")
        self.removeFromSuperview()
        self.delegate?.popupClosed()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
