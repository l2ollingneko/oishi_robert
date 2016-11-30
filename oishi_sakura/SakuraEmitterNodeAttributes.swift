//
//  SakuraEmitterNodeAttributes.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/24/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import Foundation

class SakuraEmitterNodeAttributes {
    
    static let keys = [
        "birthRate",
        "lifetime",
        "lifetimeRange",
        "positionRangeDx",
        "positionRangeDy",
        "rotation",
        "rotationRange",
        "rotationSpeed",
        "speed",
        "speedRange",
        "scale",
        "scaleRange",
        "scaleSpeed",
        "alpha",
        "alphaRange",
        "alphaSpeed"
    ]
    
    static let attributes: Dictionary<String, [CGFloat]> = [
        SakuraEmitterNodeAttributes.keys[0] : [
            10.0, 12.0, 10.0, 3.0, 2.0, 1.0
        ],
        SakuraEmitterNodeAttributes.keys[1] : [
            3.0, 3.0, 1.5, 1.0, 3.0, 3.0
        ],
        SakuraEmitterNodeAttributes.keys[2] : [
            0.0, 0.0, 0.0, 0.5, 0.0, 0.0
        ],
        SakuraEmitterNodeAttributes.keys[3] : [
            20.0, 20.0, 20.0, 20.0, 20.0, 20.0
        ],
        SakuraEmitterNodeAttributes.keys[4] : [
            5.0, 5.0, 5.0, 5.0, 5.0, 5.0
        ],
        SakuraEmitterNodeAttributes.keys[5] : [
            180.0, 180.0, 180.0, 180.0, 180.0, 180.0
        ],
        SakuraEmitterNodeAttributes.keys[6] : [
            45.0, 90.0, 45.0, 45.0, 45.0, 45.0
        ],
        SakuraEmitterNodeAttributes.keys[7] : [
            5.0, 5.0, 5.0, 5.0, 5.0, 5.0
        ],
        SakuraEmitterNodeAttributes.keys[8] : [
            500.0, 500.0, 400.0, 500.0, 500.0, 500.0
        ],
        SakuraEmitterNodeAttributes.keys[9] : [
            500.0, 500.0, -500.0, 300.0, 500.0, 500.0
        ],
        SakuraEmitterNodeAttributes.keys[10] : [
            0.025, 0.025, 0.03, 0.01, 0.015, 0.01
        ],
        SakuraEmitterNodeAttributes.keys[11] : [
            0.025, 0.025, 0.025, 0.1, 0.025, 0.01
        ],
        SakuraEmitterNodeAttributes.keys[12] : [
            0.05, 0.05, 0.015, -0.005, 0.03, 0.025
        ],
        SakuraEmitterNodeAttributes.keys[13] : [
            1.0, 1.0, 1.0, 1.0, 1.0, 1.0
        ],
        SakuraEmitterNodeAttributes.keys[14] : [
            0.5, 0.5, 0.5, 0.0, 0.5, 0.5
        ],
        SakuraEmitterNodeAttributes.keys[15] : [
            1.0, -0.1, -0.25, -0.25, 1.0, 1.0
        ]
    ]
    
    static let birthRate: [CGFloat] = [
    ]
    
    static let lifetime: [CGFloat] = [
    ]
    
    static let lifetimeRange: [CGFloat] = [
    ]
    
    static let positionRangeDx: [CGFloat] = [
    ]
    
    static let positionRangeDy: [CGFloat] = [
    ]
    
    static let rotation: [CGFloat] = [
    ]
    
    static let rotationRange: [CGFloat] = [
    ]
    
    static let rotationSpeed: [CGFloat] = [
    ]
    
    static let speed: [CGFloat] = [
    ]
    
    static let speedRange: [CGFloat] = [
    ]
    
    static let scale: [CGFloat] = [
    ]
    
    static let scaleRange: [CGFloat] = [
    ]
    
    static let scaleSpeed: [CGFloat] = [
    ]
    
    static let alpha: [CGFloat] = [
    ]
    
    static let alphaRange: [CGFloat] = [
    ]
    
    static let alphaSpeed: [CGFloat] = [
    ]
    
}
