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
        "birthRate",        // 0
        "lifetime",         // 1
        "lifetimeRange",    // 2
        "positionRangeDx",  // 3
        "positionRangeDy",  // 4
        "rotation",         // 5
        "rotationRange",    // 6
        "rotationSpeed",    // 7
        "speed",            // 8
        "speedRange",       // 9
        "scale",            // 10
        "scaleRange",       // 11
        "scaleSpeed",       // 12
        "alpha",            // 13
        "alphaRange",       // 14
        "alphaSpeed"        // 15
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
    
    static var birthRate: [CGFloat] = [ 10.0, 12.0, 10.0, 3.0, 2.0, 1.0 ]
    
    static func genBirthRate() {
        //  10.0, 12.0, 10.0, 3.0, 2.0, 1.0
        birthRate = [
            (5.0...15.0).random(),
            (7.0...15.0).random(),
            (5.0...15.0).random(),
            (1.0...8.0).random(),
            (1.0...7.0).random(),
            (1.0...6.0).random()
        ]
        print("birthRate \t\(String(describing: birthRate))")
    }
    
    static var lifetime: [CGFloat] = [ 3.0, 3.0, 1.5, 1.0, 3.0, 3.0 ]
    
    static func genLifetime() {
        // 3.0, 3.0, 1.5, 1.0, 3.0, 3.0
        lifetime = [
            (3.0...3.0).random(),
            (3.0...3.0).random(),
            (1.5...1.5).random(),
            (1.0...1.0).random(),
            (3.0...3.0).random(),
            (3.0...3.0).random()
        ]
        print("lifetime \t\(String(describing: lifetime))")
    }
    
    static var lifetimeRange: [CGFloat] = [ 0.0, 0.0, 0.0, 0.5, 0.0, 0.0 ]
    
    static func genLifetimeRange() {
        // 0.0, 0.0, 0.0, 0.5, 0.0, 0.0
        lifetimeRange = [
            (0.0...0.0).random(),
            (0.0...0.0).random(),
            (0.0...0.0).random(),
            (0.5...0.5).random(),
            (0.0...0.0).random(),
            (0.0...0.0).random()
        ]
        print("lifetimeRange \t\(String(describing: lifetimeRange))")
    }
    
    static var positionRangeDx: [CGFloat] = [ 20.0, 20.0, 20.0, 20.0, 20.0, 20.0 ]
    
    static func genPositionRangeDx() {
        // 20.0, 20.0, 20.0, 20.0, 20.0, 20.0
        positionRangeDx = [
            (20.0...20.0).random(),
            (20.0...20.0).random(),
            (20.0...20.0).random(),
            (20.0...20.0).random(),
            (20.0...20.0).random(),
            (20.0...20.0).random()
        ]
        print("positionRangeDx \t\(String(describing: positionRangeDx))")
    }
    
    static var positionRangeDy: [CGFloat] = [ 5.0, 5.0, 5.0, 5.0, 5.0, 5.0 ]
    
    static func genPositionRangeDy() {
        // 5.0, 5.0, 5.0, 5.0, 5.0, 5.0
        positionRangeDy = [
            (5.0...5.0).random(),
            (5.0...5.0).random(),
            (5.0...5.0).random(),
            (5.0...5.0).random(),
            (5.0...5.0).random(),
            (5.0...5.0).random()
        ]
        print("positionRangeDy \t\(String(describing: positionRangeDy))")
    }
    
    static var rotation: [CGFloat] = [ 180.0, 180.0, 180.0, 180.0, 180.0, 180.0 ]
    
    static func genRotation() {
        // 180.0, 180.0, 180.0, 180.0, 180.0, 180.0
        rotation = [
            (180.0...180.0).random(),
            (180.0...180.0).random(),
            (180.0...180.0).random(),
            (180.0...180.0).random(),
            (180.0...180.0).random(),
            (180.0...180.0).random()
        ]
        print("rotation \t\(String(describing: rotation))")
    }
    
    static var rotationRange: [CGFloat] = [ 45.0, 90.0, 45.0, 45.0, 45.0, 45.0 ]
    
    static func genRotationRange() {
        // 45.0, 90.0, 45.0, 45.0, 45.0, 45.0
        rotationRange = [
            (0.0...90.0).random(),
            (0.0...90.0).random(),
            (0.0...90.0).random(),
            (0.0...90.0).random(),
            (0.0...90.0).random(),
            (0.0...90.0).random()
        ]
        print("rotationRange \t\(String(describing: rotationRange))")
    }
    
    static var rotationSpeed: [CGFloat] = [ 5.0, 5.0, 5.0, 5.0, 5.0, 5.0 ]
    
    static func genRotationSpeed() {
        // 5.0, 5.0, 5.0, 5.0, 5.0, 5.0
        rotationSpeed = [
            (1.0...10.0).random(),
            (1.0...10.0).random(),
            (1.0...10.0).random(),
            (1.0...10.0).random(),
            (1.0...10.0).random(),
            (1.0...10.0).random()
        ]
        print("rotationSpeed \t\(String(describing: rotationSpeed))")
    }
    
    static var speed: [CGFloat] = [ 500.0, 500.0, 400.0, 500.0, 500.0, 500.0 ]
    
    static func genSpeed() {
        // 500.0, 500.0, 400.0, 500.0, 500.0, 500.0
        speed = [
            (400.0...600.0).random(),
            (400.0...600.0).random(),
            (300.0...500.0).random(),
            (400.0...600.0).random(),
            (400.0...600.0).random(),
            (400.0...600.0).random()
        ]
        print("speed \t\(String(describing: speed))")
    }
    
    static var speedRange: [CGFloat] = [ 500.0, 500.0, -500.0, 300.0, 500.0, 500.0 ]
    
    static func genSpeedRange() {
        // 500.0, 500.0, -500.0, 300.0, 500.0, 500.0
        speedRange = [
            (0.0...500.0).random(),
            (0.0...500.0).random(),
            (-500.0...0.0).random(),
            (0.0...500.0).random(),
            (0.0...500.0).random(),
            (0.0...500.0).random()
        ]
        print("speedRange \t\(String(describing: speedRange))")
    }
    
    static var scale: [CGFloat] = [ 0.025, 0.025, 0.03, 0.01, 0.015, 0.01 ]
    
    static func genScale() {
        // 0.025, 0.025, 0.03, 0.01, 0.015, 0.01
        scale = [
            (0.025...0.025).random(),
            (0.025...0.025).random(),
            (0.03...0.03).random(),
            (0.01...0.01).random(),
            (0.015...0.015).random(),
            (0.01...0.01).random()
        ]
        print("scale \t\(String(describing: scale))")
    }
    
    static var scaleRange: [CGFloat] = [ 0.025, 0.025, 0.025, 0.1, 0.025, 0.01 ]
    
    static func genScaleRange() {
        // 0.025, 0.025, 0.025, 0.1, 0.025, 0.01
        scaleRange = [
            (0.020...0.030).random(),
            (0.020...0.030).random(),
            (0.020...0.030).random(),
            (0.005...0.015).random(),
            (0.020...0.030).random(),
            (0.005...0.015).random()
        ]
        print("scaleRange \t\(String(describing: scaleRange))")
    }
    
    static var scaleSpeed: [CGFloat] = [ 0.05, 0.05, 0.015, -0.005, 0.03, 0.025 ]
    
    static func genScaleSpeed() {
        // 0.05, 0.05, 0.015, -0.005, 0.03, 0.025
        scaleSpeed = [
            (0.03...0.1).random(),
            (0.03...0.1).random(),
            (0.010...0.1).random(),
            (-0.010 ... -0.001).random(),
            (0.01...0.1).random(),
            (0.020...0.030).random()
        ]
        print("scaleSpeed \t\(String(describing: scaleSpeed))")
    }
    
    static var alpha: [CGFloat] = [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 ]
    
    static func genAlpha() {
        // 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
        alpha = [
            (1.0...1.0).random(),
            (1.0...1.0).random(),
            (1.0...1.0).random(),
            (1.0...1.0).random(),
            (1.0...1.0).random(),
            (1.0...1.0).random()
        ]
        print("alpha \t\(String(describing: alpha))")
    }
    
    static var alphaRange: [CGFloat] = [ 0.5, 0.5, 0.5, 0.0, 0.5, 0.5 ]
    
    static func genAlphaRange() {
        // 0.5, 0.5, 0.5, 0.0, 0.5, 0.5
        alphaRange = [
            (0.5...0.5).random(),
            (0.5...0.5).random(),
            (0.5...0.5).random(),
            (0.5...0.5).random(),
            (0.5...0.5).random(),
            (0.5...0.5).random()
        ]
        print("alphaRange \t\(String(describing: alphaRange))")
    }
    
    static var alphaSpeed: [CGFloat] = [ 1.0, -0.1, -0.25, -0.25, 1.0, 1.0 ]
    
    static func genAlphaSpeed() {
        // 1.0, -0.1, -0.25, -0.25, 1.0, 1.0
        alphaSpeed = [
            (0.0...1.0).random(),
            (-0.1 ... 0.0).random(),
            (-0.25 ... 0.0).random(),
            (-0.25 ... 0.0).random(),
            (0.0...1.0).random(),
            (0.0...1.0).random()
        ]
        print("alphaSpeed \t\(String(describing: alphaSpeed))")
    }
    
    static func genAttributes() {
        genBirthRate()
        genLifetime()
        genLifetimeRange()
        genPositionRangeDx()
        genPositionRangeDy()
        genRotation()
        genRotationRange()
        genRotationSpeed()
        genSpeed()
        genSpeedRange()
        genScale()
        genScaleRange()
        genScaleSpeed()
        genAlpha()
        genAlphaRange()
        genAlphaSpeed()
    }
    
}

extension ClosedRange where Bound : FloatingPoint {
    public func random() -> Bound {
        let range = self.upperBound - self.lowerBound
        let randomValue = (Bound(arc4random_uniform(UINT32_MAX)) / Bound(UINT32_MAX)) * range + self.lowerBound
        return randomValue
    }
}
