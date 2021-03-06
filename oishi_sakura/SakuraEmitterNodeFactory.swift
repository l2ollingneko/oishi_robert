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
let kEmitterNodeDirecion = "direcion"
let kEmitterNodeException = "exception"

class SakuraEmitterNodeFactory {
    
    static let sharedInstance = SakuraEmitterNodeFactory()
    
    private(set) var lockEmitterNodeFactory: Bool = false
    
    private var staticTextures: [Int: [String]] = [
        0: ["", "sakura_2", "sakura_3", "", "", ""],
        1: ["", "", "", "sakura_4", "sakura_5", "sakura_6"],
        2: ["sakura_1", "", "", "sakura_4", "sakura_5", "sakura_6"],
        3: ["sakura_1", "", "", "sakura_4", "sakura_5", "sakura_6"]
    ]
    
    private init() {}
    
    func createEmitterNodes(nodes: inout [SKEmitterNode]?, state: Int, settings: Dictionary<String, AnyObject>) {
        
        self.lockEmitterNodeFactory = true
        
        if (state == -99) {
            // random
            SakuraEmitterNodeAttributes.genAttributes()
        
            if nodes == nil {
                nodes = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
            }
            
            for i in 0...5 {
                let node = self.createEmitterNode(index: i)
                var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(i)"
                if let direction = settings[kEmitterNodeDirecion] as! String? {
                    name = "\(name)_\(direction)"
                }
                node.name = name
                if let emissionAngle = settings[kEmitterNodeEmissionAngle] as! CGFloat? {
                    node.emissionAngle = CGFloat(emissionAngle * .pi / 180.0)
                } else {
                    node.emissionAngle = CGFloat(270 * .pi / 180.0)
                }
                node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
                if nodes != nil {
                    nodes![i] = node
                }
                node.userData = [
                    "initialBirthRate": node.particleBirthRate,
                    "initialScale": node.particleScale,
                    "initialScaleRange": node.particleScaleRange,
                    "initialScaleSpeed": node.particleScaleSpeed
                ]
            }
            
        } else if (state >= StateManager.sharedInstance.currentState) {
            
            // SakuraEmitterNodeAttributes.genAttributes()
            
            print("create with state: \(state)")
            
            var numberOfNodes: Int = 4
            if (state == 0) {
                numberOfNodes = 3
            } else if (state == 3) {
                numberOfNodes = 5
            }
            
            if nodes == nil {
                nodes = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
                print("no any nodes, create all nodes with default")
            }
            
            for index in 1...6 {
                if let imageNamed = self.staticTextures[state]?[index-1] {
                    if (imageNamed != "") {
                        if (nodes![index-1].name == nil) {
                            // create new node
                            var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(index)"
                            if let direction = settings[kEmitterNodeDirecion] as! String? {
                                name = "\(name)_\(direction)"
                            }
                            print("create node name \(name)")
                            let node = self.createEmitterNode(index: index - 1, name: "FUCK")
                            node.name = name
                            node.particleTexture = SKTexture(imageNamed: imageNamed)
                            if let emissionAngle = settings[kEmitterNodeEmissionAngle] as! CGFloat? {
                                node.emissionAngle = CGFloat(emissionAngle * .pi / 180.0)
                            } else {
                                node.emissionAngle = CGFloat(270 * .pi / 180.0)
                            }
                            node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
                            nodes![index-1] = node
                        }
                    } else {
                        var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(index)"
                        if let direction = settings[kEmitterNodeDirecion] as! String? {
                            name = "\(name)_\(direction)"
                        }
                        let node = self.createEmitterNode(index: index - 1)
                        node.userData = [
                            "name": name,
                            "initialBirthRate": node.particleBirthRate,
                            "initialScale": node.particleScale,
                            "initialScaleRange": node.particleScaleRange,
                            "initialScaleSpeed": node.particleScaleSpeed
                        ]
                        nodes![index-1] = node
                    }
                }
            }
            
            // StateManager.sharedInstance.increaseState()
        } else {
            if let _ = settings[kEmitterNodeException] {
                var numberOfNodes: Int = 4
                if (state == 0) {
                    numberOfNodes = 3
                } else if (state == 3) {
                    numberOfNodes = 5
                }
                
                if nodes == nil {
                    nodes = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
                    print("no any nodes, create all nodes with default")
                }
                
                for index in 1...6 {
                    if let imageNamed = self.staticTextures[state]?[index-1] {
                        if (imageNamed != "") {
                            if (nodes![index-1].name == nil) {
                                // create new node
                                var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(index)"
                                if let direction = settings[kEmitterNodeDirecion] as! String? {
                                    name = "\(name)_\(direction)"
                                }
                                print("create node name \(name)")
                                let node = self.createEmitterNode(index: index - 1, name: "FUCK")
                                node.name = name
                                node.particleTexture = SKTexture(imageNamed: imageNamed)
                                if let emissionAngle = settings[kEmitterNodeEmissionAngle] as! CGFloat? {
                                    node.emissionAngle = CGFloat(emissionAngle * .pi / 180.0)
                                } else {
                                    node.emissionAngle = CGFloat(270 * .pi / 180.0)
                                }
                                node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
                                nodes![index-1] = node
                            }
                        } else {
                            var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(index)"
                            if let direction = settings[kEmitterNodeDirecion] as! String? {
                                name = "\(name)_\(direction)"
                            }
                            let node = self.createEmitterNode(index: index - 1)
                            node.userData = [
                                "name": name,
                                "initialBirthRate": node.particleBirthRate,
                                "initialScale": node.particleScale,
                                "initialScaleRange": node.particleScaleRange,
                                "initialScaleSpeed": node.particleScaleSpeed
                            ]
                            nodes![index-1] = node
                        }
                    }
                }
            }
        }
        
        self.lockEmitterNodeFactory = false
        
    }
    
    func createEmitterNodes(nodes: inout [SKEmitterNode]?, state: Int, settings: Dictionary<String, AnyObject>, cb: Callback<Bool>) {
        
        self.lockEmitterNodeFactory = true
        
        if (state == -99) {
            // random
            SakuraEmitterNodeAttributes.genAttributes()
        
            if nodes == nil {
                nodes = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
            }
            
            for i in 0...5 {
                let node = self.createEmitterNode(index: i)
                var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(i)"
                if let direction = settings[kEmitterNodeDirecion] as! String? {
                    name = "\(name)_\(direction)"
                }
                node.name = name
                if let emissionAngle = settings[kEmitterNodeEmissionAngle] as! CGFloat? {
                    node.emissionAngle = CGFloat(emissionAngle * .pi / 180.0)
                } else {
                    node.emissionAngle = CGFloat(270 * .pi / 180.0)
                }
                node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
                if nodes != nil {
                    nodes![i] = node
                }
            }
            
        } else if (state >= StateManager.sharedInstance.currentState) {
            SakuraEmitterNodeAttributes.genAttributes()
            
            print("create with state: \(state)")
            
            var numberOfNodes: Int = 4
            if (state == 0) {
                numberOfNodes = 3
            } else if (state == 3) {
                numberOfNodes = 5
            }
            
            if nodes == nil {
                nodes = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
            }
            
            for index in 1...6 {
                if let imageNamed = self.staticTextures[state]?[index-1] {
                    if (imageNamed != "") {
                        if (nodes![index-1].name == nil) {
                            // create new node
                            var name = "tid\(settings[kEmitterNodeNamePrefix]!)_sakura_node_\(index)"
                            if let direction = settings[kEmitterNodeDirecion] as! String? {
                                name = "\(name)_\(direction)"
                            }
                            print("create node name \(name)")
                            let node = self.createEmitterNode(index: index - 1)
                            node.name = name
                            node.particleTexture = SKTexture(imageNamed: imageNamed)
                            if let emissionAngle = settings[kEmitterNodeEmissionAngle] as! CGFloat? {
                                node.emissionAngle = CGFloat(emissionAngle * .pi / 180.0)
                            } else {
                                node.emissionAngle = CGFloat(270 * .pi / 180.0)
                            }
                            node.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
                            nodes![index-1] = node
                        }
                    }
                }
            }
            
            cb.callback(true, true, nil, nil)
            
            // StateManager.sharedInstance.increaseState()
        } else {
        }
        
        self.lockEmitterNodeFactory = false
        
    }
    
    func createMouthEmitterNodes() -> [SKEmitterNode] {
        
        SakuraEmitterNodeAttributes.genAttributes()
        
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
        
        node.particleBirthRate          = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[0]]?[index])!
        
        node.particleLifetime           = (SakuraEmitterNodeAttributes.lifetime[index])
        node.particleLifetimeRange      = (SakuraEmitterNodeAttributes.lifetimeRange[index])
        
        node.particlePositionRange.dx   = (SakuraEmitterNodeAttributes.positionRangeDx[index])
        node.particlePositionRange.dy   = (SakuraEmitterNodeAttributes.positionRangeDy[index])
        
        node.particleRotation           = (SakuraEmitterNodeAttributes.rotation[index])
        node.particleRotationRange      = (SakuraEmitterNodeAttributes.rotationRange[index])
        node.particleRotationSpeed      = (SakuraEmitterNodeAttributes.rotationSpeed[index])
        
        node.particleSpeed              = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[8]]?[index])!
        node.particleSpeedRange         = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[9]]?[index])!
        
        node.particleScale              = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[10]]?[index])!
        node.particleScaleRange         = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[11]]?[index])!
        node.particleScaleSpeed         = (SakuraEmitterNodeAttributes.attributes[SakuraEmitterNodeAttributes.keys[12]]?[index])!
        
        node.particleAlpha              = (SakuraEmitterNodeAttributes.alpha[index])
        node.particleAlphaRange         = (SakuraEmitterNodeAttributes.alphaRange[index])
        node.particleAlphaSpeed         = (SakuraEmitterNodeAttributes.alphaSpeed[index])
        
        return node
    }
    
}
