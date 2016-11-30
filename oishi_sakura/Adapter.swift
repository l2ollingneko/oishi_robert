//
//  Adapter.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/24/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import UIKit
import Foundation

class Adapter {
    
    static let isiPadSize: Bool = UIScreen.main.bounds.size.height / UIScreen.main.bounds.size.width < 1.5
    
    static let dWidth: CGFloat = 1242.0
    static let dHeight: CGFloat = 2208.0
    
    static let rWidth: CGFloat = isiPadSize ? 540.0 : UIScreen.main.bounds.size.width
    static let rHeight: CGFloat = isiPadSize ? 960.0 : UIScreen.main.bounds.size.height
    
    static let dNavigationBarSize: CGSize = CGSize(width: Adapter.rWidth, height: 168.0)
    static let dTabBarSize: CGSize = CGSize(width: Adapter.rWidth, height: 160.0)
    
    static let navigationBarHeight: CGFloat = (Adapter.dNavigationBarSize.height / Adapter.dHeight) * Adapter.rHeight
    static let tabBarHeight: CGFloat = (Adapter.dTabBarSize.height / Adapter.dHeight) * Adapter.rHeight
    
    static let sharedInstance = Adapter()
    
    private init() {}
    
    class func calculatedWidthFromRatio(width: CGFloat) -> CGFloat {
        return (width / Adapter.dWidth) * Adapter.rWidth
    }
    
    class func calculatedHeightFromRatio(height: CGFloat) -> CGFloat {
        return (height / Adapter.dHeight) * Adapter.rHeight
    }
    
    class func calculatedRectFromRatio(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> CGRect {
        return CGRect(x: Adapter.calculatedWidthFromRatio(width: x), y: Adapter.calculatedHeightFromRatio(height: y), width: Adapter.calculatedWidthFromRatio(width: w), height: Adapter.calculatedHeightFromRatio(height: h))
    }
    
}
