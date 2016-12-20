//
//  SharePopup.swift
//  OISHI
//
//  Created by Witsarut Suwanich on 12/20/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import Foundation
import SwiftHEXColors

protocol SharePopupDelegate {
    func buttonDidTap(buttonType: ShareButtonType)
}

class SharePopup: UIView {
    
    var actionView: UIView = UIView()
    
    var fbButton: ShareButton = ShareButton(frame: Adapter.calculatedRectFromRatio(x: 0.0, y: 137.0, w: 1242.0, h: 252.0), buttonType: .facebook)
    var twButton: ShareButton = ShareButton(frame: Adapter.calculatedRectFromRatio(x: 0.0, y: 389.0, w: 1242.0, h: 252.0), buttonType: .twitter)
    var gpButton: ShareButton = ShareButton(frame: Adapter.calculatedRectFromRatio(x: 0.0, y: 641.0, w: 1242.0, h: 252.0), buttonType: .googlePlus)
    var copyButton: ShareButton = ShareButton(frame: Adapter.calculatedRectFromRatio(x: 0.0, y: 893.0, w: 1242.0, h: 252.0), buttonType: .copyUrl)
    
    var tapGesture: UITapGestureRecognizer?
    
    var delegate: SharePopupDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        self.isUserInteractionEnabled = true
        self.actionView.isUserInteractionEnabled = true
        
        // top 137.0, buttons 252.0
        
        self.actionView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 1060.0, w: 1242.0, h: 1148.0)
        self.actionView.backgroundColor = UIColor.white
        
        let topView: UIView = UIView(frame: Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: 1242.0, h: 137.0))
        topView.backgroundColor = UIColor(hexString: "#e6e6e6")
        let label: UILabel = UILabel(frame: Adapter.calculatedRectFromRatio(x: 0.0, y: 0.0, w: 1242.0, h: 137.0))
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.text = "Share to"
        topView.addSubview(label)
        
        self.actionView.addSubview(topView)
        
        self.actionView.layer.zPosition = 500
        
        self.fbButton.delegate = self
        self.twButton.delegate = self
        self.gpButton.delegate = self
        self.copyButton.delegate = self
        
        self.actionView.addSubview(self.fbButton)
        self.actionView.addSubview(self.twButton)
        self.actionView.addSubview(self.gpButton)
        self.actionView.addSubview(self.copyButton)
        
        self.addSubview(self.actionView)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(SharePopup.didTap))
        self.tapGesture?.delegate = self
        self.addGestureRecognizer(self.tapGesture!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTap() {
        self.removeFromSuperview()
    }
    
}

extension SharePopup: UIGestureRecognizerDelegate {
    
    /*
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view == self.fbButton || touch.view == self.twButton || touch.view == self.gpButton || touch.view == self.copyButton) {
            return false
        } else {
            return true
        }
    }*/
    
}

extension SharePopup: ShareButtonDelegate {
    
    func buttonDidTap(buttonType: ShareButtonType) {
        switch buttonType {
            case .facebook:
                self.delegate?.buttonDidTap(buttonType: buttonType)
            break
            case .twitter:
                self.delegate?.buttonDidTap(buttonType: buttonType)
            break
            case .googlePlus:
                self.delegate?.buttonDidTap(buttonType: buttonType)
            break
            case .copyUrl:
                self.delegate?.buttonDidTap(buttonType: buttonType)
            break
        }
    }
    
}
