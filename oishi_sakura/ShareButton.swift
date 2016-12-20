//
//  ShareButton.swift
//  OISHI
//
//  Created by Witsarut Suwanich on 12/20/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import Foundation

enum ShareButtonType {
    case facebook, twitter, googlePlus, copyUrl
}

protocol ShareButtonDelegate {
    func buttonDidTap(buttonType: ShareButtonType)
}

class ShareButton: UIView {
    
    var logoImageView: UIImageView = UIImageView()
    var nameLabel: UILabel = UILabel()
    var separatorLine: UIView = UIView()
    var button: UIButton = UIButton()
    
    var type: ShareButtonType?
    
    var delegate: ShareButtonDelegate?
    
    init(frame: CGRect, buttonType: ShareButtonType) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.white
        
        self.isUserInteractionEnabled = true
        
        self.logoImageView.frame = Adapter.calculatedRectFromRatio(x: 0.0, y: 40.0, w: 251.0, h: 173.0)
        self.nameLabel.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 312.0), y: 0.0, width: 300.0, height: frame.size.height)
        self.separatorLine.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 60.0), y: frame.size.height - 1.0, width: frame.size.width - 60.0, height: 0.5)
        self.button.frame = CGRect.init(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        // self.button.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        
        self.type = buttonType
        
        var image: UIImage!
        var name: String!
        switch buttonType {
            case .facebook:
                image = UIImage(named: "fb")
                name = "Facebook"
            break
            case .twitter:
                image = UIImage(named: "tw")
                name = "Twitter"
            break
            case .googlePlus:
                image = UIImage(named: "gp")
                name = "Google+"
            break
            case .copyUrl:
                image = UIImage(named: "copy")
                name = "Copy URL"
            break
        }
        
        // logo
        self.logoImageView.image = image
        
        // label
        self.nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.nameLabel.text = name
        
        // separator
        self.separatorLine.backgroundColor = UIColor.gray
        
        // button
        self.button.addTarget(self, action: #selector(ShareButton.buttonDidTap), for: .touchUpInside)
        
        self.addSubview(self.logoImageView)
        self.addSubview(self.nameLabel)
        if (buttonType != .copyUrl) {
            self.addSubview(self.separatorLine)
        }
        self.addSubview(self.button)
        self.bringSubview(toFront: self.button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonDidTap() {
        self.delegate?.buttonDidTap(buttonType: self.type!)
    }
    
}
