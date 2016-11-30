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

class SakuraEmitterNodeFactory {
    
    static let sharedInstance = SakuraEmitterNodeFactory()
    
    private init() {}
    
    func createMouthEmitterNodes() -> [SKEmitterNode] {
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
        
        node.particleBirthRate = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[0]]?[index])!
        
        node.particleLifetime = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[1]]?[index])!
        node.particleLifetimeRange = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[2]]?[index])!
        
        node.particlePositionRange.dx = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[3]]?[index])!
        node.particlePositionRange.dy = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[4]]?[index])!
        
        node.particleRotation = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[5]]?[index])!
        node.particleRotationRange = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[6]]?[index])!
        node.particleRotationSpeed = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[7]]?[index])!
        
        node.particleSpeed = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[8]]?[index])!
        node.particleSpeedRange = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[9]]?[index])!
        
        node.particleScale = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[10]]?[index])!
        node.particleScaleRange = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[11]]?[index])!
        node.particleScaleSpeed = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[12]]?[index])!
        
        node.particleAlpha = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[13]]?[index])!
        node.particleAlphaRange = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[14]]?[index])!
        node.particleAlphaSpeed = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[15]]?[index])!
        
        return node
    }
    
}
