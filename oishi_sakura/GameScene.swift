//
//  GameScene.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/17/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import SpriteKit
import SceneKit
import GameplayKit
import GoogleMobileVision

enum SakuraState {
    case White, Pink
}

class GameScene: SKScene {
    
    // static var
    
    private let mouthLightRadiusRatio: CGFloat = 0.125
    private let earsLightRadiusRatio: CGFloat = 0.1
    private let eyesLightRadiusRatio: CGFloat = 0.1
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var lightEmitterNode : SKEmitterNode?
    
    private var radiusNods: Dictionary<UInt, [SKSpriteNode]> = Dictionary<UInt, [SKSpriteNode]>()
    private var mouthEmitterNodes : Dictionary<UInt, [SKEmitterNode]> = Dictionary<UInt, [SKEmitterNode]>()
    
    private var leftEarEmitterNodes: Dictionary<UInt, [SKEmitterNode]> = Dictionary<UInt, [SKEmitterNode]>()
    private var rightEarEmitterNodes: Dictionary<UInt, [SKEmitterNode]> = Dictionary<UInt, [SKEmitterNode]>()
    
    private var leftEyeEmitterNodes: Dictionary<UInt, [SKEmitterNode]> = Dictionary<UInt, [SKEmitterNode]>()
    private var rightEyeEmitterNodes: Dictionary<UInt, [SKEmitterNode]> = Dictionary<UInt, [SKEmitterNode]>()
    
    private var leftCheekImageView: UIImageView = UIImageView()
    private var rightCheekImageView: UIImageView = UIImageView()
    
    private var playSound: Bool = false
    
    private var soundAction: SKAction?
    
    private var lightNode: SKSpriteNode?
    
    private var leftCheekNode: SKSpriteNode?
    private var rightCheekNode: SKSpriteNode?
    
    private var lockEmitterNodes: Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.createLightEmitterNode()
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        // init light node
        self.lightNode = SKSpriteNode(imageNamed: "light_radius")
        // self.lightNode = SKSpriteNode(texture: SKTexture(imageNamed: "light_radius"), size: CGSize.init(width: w, height: w))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointDetected(atPoint pos: CGPoint) {
    }
    
    func pointDetected(face: GMVFaceFeature, atPoint pos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if (!self.lockEmitterNodes) {
            // radius
            if let node = self.childNode(withName: "tid\(face.trackingID)_radius") as! SKSpriteNode? {
                node.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
                node.position = pos
            } else {
                if let n = self.lightNode?.copy() as! SKSpriteNode? {
                    n.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
                    n.name = "tid\(face.trackingID)_radius"
                    n.position = pos
                    self.addChild(n)
                }
            }
            
            // light emitter
            if let node = self.childNode(withName: "tid\(face.trackingID)_light_node") {
                node.position = pos
                (node as! SKEmitterNode).emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
                if (!self.playSound) {
                }
            } else {
                if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                    n.name = "tid\(face.trackingID)_light_node"
                    n.position = pos
                    n.emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
                    self.addChild(n)
                }
            }
     
            if let node = self.childNode(withName: "sound") as! SKAudioNode? {
            } else {
                let sound = SKAudioNode(fileNamed: "sfx.aiff")
                sound.name = "sound"
                self.addChild(sound)
            }
        
            if let nodes = self.mouthEmitterNodes[face.trackingID] {
                if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                    for node in nodes {
                        if let name = node.name {
                            if let node = self.childNode(withName: "\(name)") {
                                node.position = pos
                                (node as! SKEmitterNode).emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
                            } else {
                                node.position = pos
                                self.addChild(node)
                            }
                        }
                    }
                }
            } else {
                // TODO: - do nothing, wait for controller to tell gamescene to create nodes
            }
            
        } else {
            print("lockEmitterNodes")
        }
    }
    
    func earsPointDetected(face: GMVFaceFeature, lpos: CGPoint, rpos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        // radius
        if let node = self.childNode(withName: "tid\(face.trackingID)_radius_left") as! SKSpriteNode? {
            node.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
            node.position = lpos
        } else {
            if let n = self.lightNode?.copy() as! SKSpriteNode? {
                n.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
                n.name = "tid\(face.trackingID)_radius_left"
                n.position = lpos
                self.addChild(n)
            }
        }
        
        // radius
        if let node = self.childNode(withName: "tid\(face.trackingID)_radius_right") as! SKSpriteNode? {
            node.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
            node.position = rpos
        } else {
            if let n = self.lightNode?.copy() as! SKSpriteNode? {
                n.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
                n.name = "tid\(face.trackingID)_radius_right"
                n.position = rpos
                self.addChild(n)
            }
        }
        
        // light emitter
        if let node = self.childNode(withName: "tid\(face.trackingID)_light_node_left") {
            node.position = lpos
            (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
            /*
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
            */
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "tid\(face.trackingID)_light_node_left"
                n.position = lpos
                n.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        if let node = self.childNode(withName: "tid\(face.trackingID)_light_node_right") {
            node.position = rpos
            (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
            /*
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
            */
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "tid\(face.trackingID)_light_node_right"
                n.position = rpos
                n.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
                self.addChild(n)
            }
        }
        
        if let node = self.childNode(withName: "sound") as! SKAudioNode? {
        } else {
            let sound = SKAudioNode(fileNamed: "sfx.aiff")
            sound.name = "sound"
            self.addChild(sound)
        }
        
        if let nodes = self.leftEarEmitterNodes[face.trackingID] {
            if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                for node in nodes {
                    if let name = node.name {
                        if let node = self.childNode(withName: "\(name)") {
                            node.position = lpos
                            (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
                        } else {
                            node.position = lpos
                            self.addChild(node)
                        }
                    }
                }
            }
        } else {
            // TODO: - do nothing, wait for controller to tell gamescene to create nodes
        }
        
        if let nodes = self.rightEarEmitterNodes[face.trackingID] {
            if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                for node in nodes {
                    if let name = node.name {
                        if let node = self.childNode(withName: "\(name)") {
                            node.position = rpos
                            (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
                        } else {
                            node.position = rpos
                            self.addChild(node)
                        }
                    }
                }
            }
        } else {
            // TODO: - do nothing, wait for controller to tell gamescene to create nodes
        }
        
    }
    
    func eyesPointDetected(face: GMVFaceFeature, lpos: CGPoint, rpos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        // radius
        if let node = self.childNode(withName: "tid\(face.trackingID)_radius_left") as! SKSpriteNode? {
            node.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
            node.position = lpos
        } else {
            if let n = self.lightNode?.copy() as! SKSpriteNode? {
                n.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
                n.name = "tid\(face.trackingID)_radius_left"
                n.position = lpos
                self.addChild(n)
            }
        }
        
        // radius
        if let node = self.childNode(withName: "tid\(face.trackingID)_radius_right") as! SKSpriteNode? {
            node.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
            node.position = rpos
        } else {
            if let n = self.lightNode?.copy() as! SKSpriteNode? {
                n.size = CGSize.init(width: (face.bounds.size.width * self.mouthLightRadiusRatio), height: (face.bounds.size.width * self.mouthLightRadiusRatio) * 248.0 / 287.0)
                n.name = "tid\(face.trackingID)_radius_right"
                n.position = rpos
                self.addChild(n)
            }
        }
        
        // light emitter
        if let node = self.childNode(withName: "tid\(face.trackingID)_light_node_left") {
            node.position = lpos
            (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
            /*
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
            */
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "tid\(face.trackingID)_light_node_left"
                n.position = lpos
                n.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
                n.speed += (n.speed / 3.0)
                self.addChild(n)
            }
        }
        
        if let node = self.childNode(withName: "tid\(face.trackingID)_light_node_right") {
            node.position = rpos
            (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
            /*
            if (!self.playSound) {
                self.playSound = true
                self.run(SKAction.playSoundFileNamed("beam.wav", waitForCompletion: true), completion: { completed in
                    self.playSound = false
                })
            }
            */
        } else {
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "tid\(face.trackingID)_light_node_right"
                n.position = rpos
                n.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
                n.speed += (n.speed / 3.0)
                self.addChild(n)
            }
        }
        
        if let node = self.childNode(withName: "sound") as! SKAudioNode? {
        } else {
            let sound = SKAudioNode(fileNamed: "sfx.aiff")
            sound.name = "sound"
            self.addChild(sound)
        }
        
         if let nodes = self.leftEyeEmitterNodes[face.trackingID] {
            if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                for node in nodes {
                    if let name = node.name {
                        if let node = self.childNode(withName: "\(name)") {
                            node.position = lpos
                            (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
                        } else {
                            node.position = lpos
                            self.addChild(node)
                        }
                    }
                }
            }
        } else {
            // TODO: - do nothing, wait for controller to tell gamescene to create nodes
        }
        
        if let nodes = self.rightEyeEmitterNodes[face.trackingID] {
            if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                for node in nodes {
                    if let name = node.name {
                        if let node = self.childNode(withName: "\(name)") {
                            node.position = rpos
                            (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
                        } else {
                            node.position = rpos
                            self.addChild(node)
                        }
                    }
                }
            }
        } else {
            // TODO: - do nothing, wait for controller to tell gamescene to create nodes
        }
        
    }
    
    func cheeksDetected(faceRect: CGRect, leftCheekPoint: CGPoint, rightCheekPoint: CGPoint) {
        self.leftCheekImageView.center = leftCheekPoint
        self.rightCheekImageView.center = rightCheekPoint
    }
    
    func removeAllNode(prefix: UInt) {
        print("emitter node count: \(self.mouthEmitterNodes[prefix]?.count)")
        
        if (self.children.count == 0 || self.mouthEmitterNodes[prefix]?.count == 0) {
            return
        }
        
        self.lockEmitterNodes = true
        
        DispatchQueue.main.sync {
            for childNode in self.children {
                if let name = childNode.name, name.contains("tid\(prefix)") {
                    print("name: \(name)")
                    if let node = self.childNode(withName: name) {
                        node.removeFromParent()
                    }
                    print("success remove node w/ name: \(name)")
                }
            }
            
            if let node = self.childNode(withName: "sound") {
                node.removeFromParent()
            }
        }
        
        print("remove sound node")
        
        self.lockEmitterNodes = false
        
        print("remove childNode")
    }
    
    func resetEmitterNodes() {
        self.lockEmitterNodes = true
        for key in self.mouthEmitterNodes.keys {
            self.mouthEmitterNodes[key]?.removeAll()
            self.mouthEmitterNodes[key] = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
        }
        for key in self.leftEarEmitterNodes.keys {
            self.leftEarEmitterNodes[key]?.removeAll()
            self.leftEarEmitterNodes[key] = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
        }
        for key in self.rightEarEmitterNodes.keys {
            self.rightEarEmitterNodes[key]?.removeAll()
            self.rightEarEmitterNodes[key] = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
        }
        for key in self.leftEyeEmitterNodes.keys {
            self.leftEyeEmitterNodes[key]?.removeAll()
            self.leftEyeEmitterNodes[key] = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
        }
        for key in self.rightEyeEmitterNodes.keys {
            self.rightEyeEmitterNodes[key]?.removeAll()
            self.rightEyeEmitterNodes[key] = [SKEmitterNode](repeating: SKEmitterNode(), count: 6)
        }
        self.lockEmitterNodes = false
    }
    
    func noPointDetected() {
        // light radius
        if let node = self.childNode(withName: "light_radius") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "left_light_radius") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "right_light_radius") {
            node.removeFromParent()
        }
        
        // light node
        if let node = self.childNode(withName: "lightnode") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "left_lightnode") {
            node.removeFromParent()
        }
        if let node = self.childNode(withName: "right_lightnode") {
            node.removeFromParent()
        }
        
        for i in 1...6 {
            if let node = self.childNode(withName: "sakura_\(i)") {
                node.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "le_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "re_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            if let leftNode = self.childNode(withName: "ly_sakura_\(i)") {
                leftNode.removeFromParent()
            }
            if let rightNode = self.childNode(withName: "ry_sakura_\(i)") {
                rightNode.removeFromParent()
            }
            
        }
    }
    
    func calculatedEmissionAngle(y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        let radY = CGFloat(y * .pi / 180.0)
        
        if (radY < -0.15) {
            if (radY < -0.3) {
                return CGFloat(180.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else if (radY > 0.15) {
            if (radY > 0.3) {
                return CGFloat(0.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else {
            if (radZ < 0) {
                
            } else {
                
            }
            return CGFloat(270.0 * .pi / 180.0) + radZ
        }
    }
    
    func calculatedEyesEmissionAngle(leftEye: Bool, y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        let radY = CGFloat(y * .pi / 180.0)
        
        if (radY < -0.15) {
            if (radY < -0.3) {
                return CGFloat(180.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else if (radY > 0.15) {
            if (radY > 0.3) {
                return CGFloat(0.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else {
            if (radZ < 0) {
                
            } else {
                
            }
            return leftEye ? CGFloat(260.0 * .pi / 180.0) + radZ : CGFloat(280.0 * .pi / 180.0) + radZ
        }
    }
    
    func calculatedEarsEmissionAngle(leftEar: Bool, y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        return leftEar ? CGFloat(180.0 * .pi / 180.0) + radZ : CGFloat(0.0 * .pi / 180.0) + radZ
    }
    
    func prepareMouthEmitterNodes() {
    }
    
    func createMouthEmitterNodes(trackingID: UInt, state: Int) {
        
        let settings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(270.0) as AnyObject
        ]
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.mouthEmitterNodes[trackingID], state: state, settings: settings)
        
        // self.mouthEmitterNodes.removeAll()
        // self.mouthEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createMouthEmitterNodes()
    }
    
    func createEyesEmitterNodes(trackingID: UInt, state: Int) {
        
        let lsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(270.0) as AnyObject,
            kEmitterNodeDirecion: "left" as AnyObject
        ]
        
        let rsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(270.0) as AnyObject,
            kEmitterNodeDirecion: "right" as AnyObject
        ]
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.leftEyeEmitterNodes[trackingID], state: state, ableToChangeState: false, settings: lsettings)
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.rightEyeEmitterNodes[trackingID], state: state, settings: rsettings)
        
        /*
        self.leftEyeEmitterNodes.removeAll()
        self.leftEyeEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createLeftEyeEmitterNodes()
        self.rightEyeEmitterNodes.removeAll()
        self.rightEyeEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createRightEyeEmitterNodes()
         */
    }
    
    func createEarsEmitterNodes(trackingID: UInt, state: Int) {
        
        let lsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(180.0) as AnyObject,
            kEmitterNodeDirecion: "left" as AnyObject
        ]
        
        let rsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(0.0) as AnyObject,
            kEmitterNodeDirecion: "right" as AnyObject
        ]
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.leftEarEmitterNodes[trackingID], state: state, ableToChangeState: false, settings: lsettings)
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.rightEarEmitterNodes[trackingID], state: state, settings: rsettings)
        
        /*
        self.leftEarEmitterNodes.removeAll()
        self.leftEarEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createLeftEarEmitterNodes()
        self.rightEarEmitterNodes.removeAll()
        self.rightEarEmitterNodes = SakuraEmitterNodeFactory.sharedInstance.createRightEarEmitterNodes()
         */
    }
    
    func createLightEmitterNode() {
        self.lightEmitterNode = SKEmitterNode(fileNamed: "LightParticle")
    }
    
    func createLightEmitterNode(state: Int) {
        if (state == 0) {
            self.lightEmitterNode = SKEmitterNode(fileNamed: "LightParticle")
        } else {
            self.lightEmitterNode = SKEmitterNode(fileNamed: "BlueLightParticle")
        }
    }
    
    func changeLightEmitterNode(pink: Bool) {
        
        self.lightEmitterNode = pink ? SKEmitterNode(fileNamed: "LightParticle") : SKEmitterNode(fileNamed: "BlueLightParticle")
        
        for child in self.children {
            if let name =  child.name, name.contains("light_node") {
                child.removeFromParent()
                if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                    let splitedString = name.components(separatedBy: "_")
                    n.name = name
                    n.position = child.position
                    n.emissionAngle = (child as! SKEmitterNode).emissionAngle
                    self.addChild(n)
                }
            }
        }
        
        
        /*
        if let node = self.childNode(withName: "lightnode") {
            // mouth
            node.removeFromParent()
            if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                n.name = "lightnode"
                n.position = node.position
                n.emissionAngle = (node as! SKEmitterNode).emissionAngle
                self.addChild(n)
            }
        } else {
            // eyes || ears
            if let node = self.childNode(withName: "left_lightnode") {
                node.removeFromParent()
                // MARK: - change emitter direction
                if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                    n.name = "left_lightnode"
                    n.position = node.position
                    n.emissionAngle = (node as! SKEmitterNode).emissionAngle
                    self.addChild(n)
                }
            }
            if let node = self.childNode(withName: "right_lightnode") {
                node.removeFromParent()
                // MARK: - change emitter direction
                if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                    n.name = "right_lightnode"
                    n.position = node.position
                    n.emissionAngle = (node as! SKEmitterNode).emissionAngle
                    self.addChild(n)
                }
                
            }
        }
         */
    }
    
    /*
    func touchDown(atPoint pos : CGPoint) {
        print("touchDown at \(pos)")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    */
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func stopActions() {
        self.removeAllActions()
        self.playSound = false
    }
    
}
