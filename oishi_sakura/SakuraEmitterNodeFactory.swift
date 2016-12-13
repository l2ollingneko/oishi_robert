//
//  SakuraEmitterFactory.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/24/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftHEXColors

let kEmitterNodeNamePrefix = "namePrefix"
let kEmitterNodeEmissionAngle = "emissionAngle"
let kEmitterNodeRound = "round"
let kEmitterNodeState = "state"
let kEmitterNodeRandom = "random"

class SakuraEmitterNodeFactory {
    
    static let sharedInstance = SakuraEmitterNodeFactory()
    
    private var staticTextures: [Int: [String]] = [
        0: ["sakura_2", "sakura_3"],
        1: ["sakura_2", "sakura_3", "sakura_1", "sakura_5"],
        2: ["sakura_1", "sakura_3", "sakura_4", "sakura_5"],
        3: ["sakura_1", "sakura_3", "sakura_4", "sakura_5", "sakura_6"]
    ]
    
    private init() {}
    
    func createEmitterNodes(settings: Dictionary<String, AnyObject>) -> [SKEmitterNode] {
        var nodes: [SKEmitterNode] = [SKEmitterNode]()
        var numberOfNodes: Int = 4
        
        if let state = settings[kEmitterNodeState] as! Int? {
            if (state == 0) {
                numberOfNodes = 2
            } else if (state == 3) {
                numberOfNodes = 5
            }
            
            for index in 1...numberOfNodes {
                let name = "\(settings[kEmitterNodeNamePrefix])_sakura_node_\(index)"
                let node = self.createEmitterNode(index: index - 1, name: name)
                node.particleTexture = SKTexture(imageNamed: "\(self.staticTextures[state]?[index-1])")
                if let emissionAngle = settings[kEmitterNodeEmissionAngle] as! CGFloat? {
                    node.emissionAngle = emissionAngle
                } else {
                    node.emissionAngle = CGFloat(270 * .pi / 180.0)
                }
                nodes.append(node)
            }
        }
        
        return nodes
    }
    
    func createMouthEmitterNodes() -> [SKEmitterNode] {
        
        // SakuraEmitterNodeAttributes.genAttributes()
        
        var nodes: [SKEmitterNode] = [SKEmitterNode]()
        for i in 0...5 {
            let node = self.createEmitterNode(index: i)
            node.name = "sakura_\(i + 1)"
            node.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
            nodes.append(node)
        }
        return nodes
    }
    
    func createLeftEyeEmitterNodes() -> [SKEmitterNode] {
        
        // SakuraEmitterNodeAttributes.genAttributes()
        
        var nodes: [SKEmitterNode] = [SKEmitterNode]()
        for i in 0...5 {
            let node = self.createEmitterNode(index: i)
            node.name = "ly_sakura_\(i + 1)"
            node.emissionAngle = CGFloat(260.0 * .pi / 180.0)
            node.emissionAngleRange = CGFloat(20.0 * .pi / 180.0)
            nodes.append(node)
        }
        return nodes
    }
    
    func createRightEyeEmitterNodes() -> [SKEmitterNode] {
        
        // SakuraEmitterNodeAttributes.genAttributes()
        
        var nodes: [SKEmitterNode] = [SKEmitterNode]()
        for i in 0...5 {
            let node = self.createEmitterNode(index: i)
            node.name = "ry_sakura_\(i + 1)"
            node.emissionAngle = CGFloat(280.0 * .pi / 180.0)
            node.emissionAngleRange = CGFloat(20.0 * .pi / 180.0)
            nodes.append(node)
        }
        return nodes
    }
    
    func createLeftEarEmitterNodes() -> [SKEmitterNode] {
        
        // SakuraEmitterNodeAttributes.genAttributes()
        
        var nodes: [SKEmitterNode] = [SKEmitterNode]()
        for i in 0...5 {
            let node = self.createEmitterNode(index: i)
            node.name = "le_sakura_\(i + 1)"
            node.emissionAngle = CGFloat(180.0 * .pi / 180.0)
            node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
            nodes.append(node)
        }
        return nodes
    }
    
    func createRightEarEmitterNodes() -> [SKEmitterNode] {
        
        // SakuraEmitterNodeAttributes.genAttributes()
        
        var nodes: [SKEmitterNode] = [SKEmitterNode]()
        for i in 0...5 {
            let node = self.createEmitterNode(index: i)
            node.name = "re_sakura_\(i + 1)"
            node.emissionAngle = CGFloat(0.0 * .pi / 180.0)
            node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
            nodes.append(node)
        }
        return nodes
    }
    
    // MARK: - create single node depend on index (1-6)
    
    func createEmitterNode(index: Int) -> SKEmitterNode {
        let node = SKEmitterNode()
        
        // texture
        node.particleTexture = SKTexture(imageNamed: "sakura_\(index + 1)")
        
        node.particleBirthRate          = (SakuraEmitterNodeAttributes.birthRate[index])
        
        node.particleLifetime           = (SakuraEmitterNodeAttributes.lifetime[index])
        node.particleLifetimeRange      = (SakuraEmitterNodeAttributes.lifetimeRange[index])
        
        node.particlePositionRange.dx   = (SakuraEmitterNodeAttributes.positionRangeDx[index])
        node.particlePositionRange.dy   = (SakuraEmitterNodeAttributes.positionRangeDy[index])
        
        node.particleRotation           = (SakuraEmitterNodeAttributes.rotation[index])
        node.particleRotationRange      = (SakuraEmitterNodeAttributes.rotationRange[index])
        node.particleRotationSpeed      = (SakuraEmitterNodeAttributes.rotationSpeed[index])
        
        node.particleSpeed              = (SakuraEmitterNodeAttributes.speed[index])
        node.particleSpeedRange         = (SakuraEmitterNodeAttributes.speedRange[index])
        
        node.particleScale              = (SakuraEmitterNodeAttributes.scale[index])
        node.particleScaleRange         = (SakuraEmitterNodeAttributes.scaleRange[index])
        node.particleScaleSpeed         = (SakuraEmitterNodeAttributes.scaleSpeed[index])
        
        node.particleAlpha              = (SakuraEmitterNodeAttributes.alpha[index])
        node.particleAlphaRange         = (SakuraEmitterNodeAttributes.alphaRange[index])
        node.particleAlphaSpeed         = (SakuraEmitterNodeAttributes.alphaSpeed[index])
        
        return node
    }
    
    func createEmitterNode(index: Int, name: String) -> SKEmitterNode {
        let node = SKEmitterNode()
        
        node.name = name
        
        node.particleBirthRate          = (SakuraEmitterNodeAttributes.birthRate[index])
        
        node.particleLifetime           = (SakuraEmitterNodeAttributes.lifetime[index])
        node.particleLifetimeRange      = (SakuraEmitterNodeAttributes.lifetimeRange[index])
        
        node.particlePositionRange.dx   = (SakuraEmitterNodeAttributes.positionRangeDx[index])
        node.particlePositionRange.dy   = (SakuraEmitterNodeAttributes.positionRangeDy[index])
        
        node.particleRotation           = (SakuraEmitterNodeAttributes.rotation[index])
        node.particleRotationRange      = (SakuraEmitterNodeAttributes.rotationRange[index])
        node.particleRotationSpeed      = (SakuraEmitterNodeAttributes.rotationSpeed[index])
        
        node.particleSpeed              = (SakuraEmitterNodeAttributes.speed[index])
        node.particleSpeedRange         = (SakuraEmitterNodeAttributes.speedRange[index])
        
        node.particleScale              = (SakuraEmitterNodeAttributes.scale[index])
        node.particleScaleRange         = (SakuraEmitterNodeAttributes.scaleRange[index])
        node.particleScaleSpeed         = (SakuraEmitterNodeAttributes.scaleSpeed[index])
        
        node.particleAlpha              = (SakuraEmitterNodeAttributes.alpha[index])
        node.particleAlphaRange         = (SakuraEmitterNodeAttributes.alphaRange[index])
        node.particleAlphaSpeed         = (SakuraEmitterNodeAttributes.alphaSpeed[index])
        
        return node
    }
    
}
