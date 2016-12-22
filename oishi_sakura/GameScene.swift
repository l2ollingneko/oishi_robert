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
import SwiftKeychainWrapper

enum SakuraState {
    case White, Pink
}

class GameScene: SKScene {
    
    // static var
    
    private let cheekRatio: CGFloat = (UIApplication.shared.delegate as! AppDelegate).isiPad ? 0.35 : 0.2
    private let mouthLightRadiusRatio: CGFloat = 0.125
    private let earsLightRadiusRatio: CGFloat = 0.1
    private let eyesLightRadiusRatio: CGFloat = 0.1
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var lightEmitterNode : SKEmitterNode?
    
    private var sakuraNode: Dictionary<UInt, [SKSpriteNode]> = Dictionary<UInt, [SKSpriteNode]>()
    private var sakura3DNode: Dictionary<UInt, [SK3DNode]> = Dictionary<UInt, [SK3DNode]>()
    
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
    
    private var willRemoveNodes: [SKNode] = [SKNode]()
    
    var recording: Bool = false
    var currentState: Int = 0
    
    var faceMultiplier: CGFloat = 0.0
    
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
        
        if (UIScreen.main.bounds.size.width < 375.0) {
            self.faceMultiplier = 0.45
        } else if (UIScreen.main.bounds.size.width < 400.0) {
            self.faceMultiplier = 0.48
        } else if (UIScreen.main.bounds.size.width < 500) {
            self.faceMultiplier = 0.61
        } else {
            self.faceMultiplier = 0.77
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointDetected(atPoint pos: CGPoint) {
    }
    
    func pointDetected(face: GMVFaceFeature, atPoint pos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if (!self.lockEmitterNodes) {
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
     
            if let nodes = self.mouthEmitterNodes[face.trackingID] {
                if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                    for node in nodes {
                        if let name = node.name {
                            if let node = self.childNode(withName: "\(name)") as? SKEmitterNode {
                                
                                // calculate mouth size vs facesize
                                let heightRatio = face.bounds.size.height / UIScreen.main.bounds.size.height
                                if let initialScale = node.userData?["initialScale"], let initialScaleRange = node.userData?["initialScaleRange"], let initialScaleSpeed = node.userData?["initialScaleSpeed"] {
                                    // let b = initialBirthRate as! CGFloat
                                    let s = initialScale as! CGFloat
                                    let ss = initialScaleRange as! CGFloat
                                    let sss = initialScaleSpeed as! CGFloat
                                    if (heightRatio > 1.0) {
                                        // node.particleBirthRate = b * (heightRatio - 0.5)
                                        node.particleScale = s * (heightRatio + 0.5)
                                        node.particleScaleRange = ss
                                        node.particleScaleSpeed = sss
                                    } else if (heightRatio < 0.5) {
                                        // node.particleBirthRate = b * (0.85 + heightRatio)
                                        node.particleScale = s * (heightRatio + 0.25)
                                        node.particleScaleRange = ss * (heightRatio)
                                        node.particleScaleSpeed = sss * (heightRatio)
                                    } else {
                                        // node.particleBirthRate = b
                                        node.particleScale = s
                                        node.particleScaleRange = ss
                                        node.particleScaleSpeed = sss
                                    }
                                }
                                
                                node.position = pos
                                node.zPosition = 1000
                                node.emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
                            } else {
                                node.position = pos
                                node.zPosition = 1000
                                self.addChild(node)
                            }
                        } else {
                            if let name = node.userData?["name"] as! String? {
                                if let node = self.childNode(withName: "\(name)") {
                                    print("remove name: \(name)")
                                    self.willRemoveNodes.append(node)
                                    // Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.removeNode), userInfo: node, repeats: false)
                                    DispatchQueue.main.async {
                                        node.removeFromParent()
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // TODO: - do nothing, wait for controller to tell gamescene to create nodes
                if (self.recording) {
                    self.createMouthEmitterNodesWithException(trackingID: face.trackingID, state: self.currentState)
                    if let nodes = self.mouthEmitterNodes[face.trackingID] {
                        for node in nodes {
                            print("\(node.name)")
                        }
                    }
                }
            }
            
        } else {
            print("lockEmitterNodes")
        }
    }
    
    func earsPointDetected(face: GMVFaceFeature, lpos: CGPoint, rpos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if (!self.lockEmitterNodes) {
            // light emitter
            if let node = self.childNode(withName: "tid\(face.trackingID)_light_node_left") {
                node.position = lpos
                (node as! SKEmitterNode).emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
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
            } else {
                if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                    n.name = "tid\(face.trackingID)_light_node_right"
                    n.position = rpos
                    n.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
                    self.addChild(n)
                }
            }
            
            if let nodes = self.leftEarEmitterNodes[face.trackingID] {
                if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                    for node in nodes {
                        if let name = node.name {
                            if let node = self.childNode(withName: "\(name)") as? SKEmitterNode {
                                let heightRatio = face.bounds.size.height / UIScreen.main.bounds.size.height
                                print("ratio: \(heightRatio)")
                                if let initialScale = node.userData?["initialScale"], let initialScaleRange = node.userData?["initialScaleRange"], let initialScaleSpeed = node.userData?["initialScaleSpeed"] {
                                    let s = initialScale as! CGFloat
                                    let ss = initialScaleRange as! CGFloat
                                    let sss = initialScaleSpeed as! CGFloat
                                    if (heightRatio > 1.0) {
                                        node.particleScale = s * (heightRatio + 0.5)
                                    } else if (heightRatio < 0.5) {
                                        node.particleScale = s * (heightRatio + 0.25)
                                        node.particleScaleRange = ss * (heightRatio)
                                        node.particleScaleSpeed = sss * (heightRatio)
                                    } else {
                                        node.particleScale = s
                                        node.particleScaleRange = ss
                                        node.particleScaleSpeed = sss
                                    }
                                }
                                node.position = lpos
                                node.zPosition = 1000
                                node.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: true, y: headEulerAngleY, z: headEulerAngleZ)
                            } else {
                                node.position = lpos
                                node.zPosition = 1000
                                self.addChild(node)
                            }
                        } else {
                            if let name = node.userData?["name"] as! String? {
                                if let node = self.childNode(withName: "\(name)") {
                                    self.willRemoveNodes.append(node)
                                    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameScene.removeNode), userInfo: node, repeats: false)
                                    // node.removeFromParent()
                                }
                            }
                        }
                    }
                }
            } else {
                // TODO: - do nothing, wait for controller to tell gamescene to create nodes
                if (self.recording) {
                    self.createEarsEmitterNodesWithException(trackingID: face.trackingID, state: self.currentState)
                }
            }
            
            if let nodes = self.rightEarEmitterNodes[face.trackingID] {
                if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                    for node in nodes {
                        if let name = node.name {
                            if let node = self.childNode(withName: "\(name)") as? SKEmitterNode {
                                let heightRatio = face.bounds.size.height / UIScreen.main.bounds.size.height
                                print("ratio: \(heightRatio)")
                                if let initialScale = node.userData?["initialScale"], let initialScaleRange = node.userData?["initialScaleRange"], let initialScaleSpeed = node.userData?["initialScaleSpeed"] {
                                    let s = initialScale as! CGFloat
                                    let ss = initialScaleRange as! CGFloat
                                    let sss = initialScaleSpeed as! CGFloat
                                    if (heightRatio > 1.0) {
                                        node.particleScale = s * (heightRatio + 0.5)
                                    } else if (heightRatio < 0.5) {
                                        node.particleScale = s * (heightRatio + 0.25)
                                        node.particleScaleRange = ss * (heightRatio)
                                        node.particleScaleSpeed = sss * (heightRatio)
                                    } else {
                                        node.particleScale = s
                                        node.particleScaleRange = ss
                                        node.particleScaleSpeed = sss
                                    }
                                }
                                node.position = rpos
                                node.zPosition = 1000
                                node.emissionAngle = self.calculatedEarsEmissionAngle(leftEar: false, y: headEulerAngleY, z: headEulerAngleZ)
                            } else {
                                node.position = rpos
                                node.zPosition = 1000
                                self.addChild(node)
                            }
                         } else {
                            if let name = node.userData?["name"] as! String? {
                                if let node = self.childNode(withName: "\(name)") {
                                    node.removeFromParent()
                                }
                            }
                        }
                    }
                }
            } else {
                // TODO: - do nothing, wait for controller to tell gamescene to create nodes
                if (self.recording) {
                    self.createEarsEmitterNodesWithException(trackingID: face.trackingID, state: self.currentState)
                }
            }
            
        }
        
    }
    
    func eyesPointDetected(face: GMVFaceFeature, lpos: CGPoint, rpos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        
        if (!self.lockEmitterNodes) {
            
            // light emitter
            if let node = self.childNode(withName: "tid\(face.trackingID)_light_node_left") {
                node.position = lpos
                (node as! SKEmitterNode).emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
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
            } else {
                if let n = self.lightEmitterNode?.copy() as! SKEmitterNode? {
                    n.name = "tid\(face.trackingID)_light_node_right"
                    n.position = rpos
                    n.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
                    n.speed += (n.speed / 3.0)
                    self.addChild(n)
                }
            }
            
             if let nodes = self.leftEyeEmitterNodes[face.trackingID] {
                if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                    for node in nodes {
                        if let name = node.name {
                            if let node = self.childNode(withName: "\(name)") as? SKEmitterNode {
                                let heightRatio = face.bounds.size.height / UIScreen.main.bounds.size.height
                                print("ratio: \(heightRatio)")
                                if let initialScale = node.userData?["initialScale"], let initialScaleRange = node.userData?["initialScaleRange"], let initialScaleSpeed = node.userData?["initialScaleSpeed"] {
                                    let s = initialScale as! CGFloat
                                    let ss = initialScaleRange as! CGFloat
                                    let sss = initialScaleSpeed as! CGFloat
                                    if (heightRatio > 1.0) {
                                        node.particleScale = s * (heightRatio + 0.5)
                                    } else if (heightRatio < 0.5) {
                                        node.particleScale = s * (heightRatio + 0.25)
                                        node.particleScaleRange = ss * (heightRatio)
                                        node.particleScaleSpeed = sss * (heightRatio)
                                    } else {
                                        node.particleScale = s
                                        node.particleScaleRange = ss
                                        node.particleScaleSpeed = sss
                                    }
                                }
                                node.position = lpos
                                node.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: true, y: headEulerAngleY, z: headEulerAngleZ)
                            } else {
                                node.position = lpos
                                self.addChild(node)
                            }
                        } else {
                            if let name = node.userData?["name"] as! String? {
                                if let node = self.childNode(withName: "\(name)") {
                                    self.willRemoveNodes.append(node)
                                    // Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameScene.removeNode), userInfo: node, repeats: false)
                                    node.removeFromParent()
                                }
                            }
                        }
                    }
                }
            } else {
                // TODO: - do nothing, wait for controller to tell gamescene to create nodes
                if (self.recording) {
                    self.createEyesEmitterNodesWithException(trackingID: face.trackingID, state: self.currentState)
                }
            }
            
            if let nodes = self.rightEyeEmitterNodes[face.trackingID] {
                if (!SakuraEmitterNodeFactory.sharedInstance.lockEmitterNodeFactory) {
                    for node in nodes {
                        if let name = node.name {
                            if let node = self.childNode(withName: "\(name)") as? SKEmitterNode {
                                let heightRatio = face.bounds.size.height / UIScreen.main.bounds.size.height
                                print("ratio: \(heightRatio)")
                                if let initialScale = node.userData?["initialScale"], let initialScaleRange = node.userData?["initialScaleRange"], let initialScaleSpeed = node.userData?["initialScaleSpeed"] {
                                    let s = initialScale as! CGFloat
                                    let ss = initialScaleRange as! CGFloat
                                    let sss = initialScaleSpeed as! CGFloat
                                    if (heightRatio > 1.0) {
                                        node.particleScale = s * (heightRatio + 0.5)
                                    } else if (heightRatio < 0.5) {
                                        node.particleScale = s * (heightRatio + 0.25)
                                        node.particleScaleRange = ss * (heightRatio)
                                        node.particleScaleSpeed = sss * (heightRatio)
                                    } else {
                                        node.particleScale = s
                                        node.particleScaleRange = ss
                                        node.particleScaleSpeed = sss
                                    }
                                }
                                node.position = rpos
                                node.zPosition = 1000
                                node.emissionAngle = self.calculatedEyesEmissionAngle(leftEye: false, y: headEulerAngleY, z: headEulerAngleZ)
                            } else {
                                node.position = rpos
                                node.zPosition = 1000
                                self.addChild(node)
                            }
                        } else {
                            if let name = node.userData?["name"] as! String? {
                                if let node = self.childNode(withName: "\(name)") {
                                    node.removeFromParent()
                                }
                            }
                        }
                    }
                }
            } else {
                // TODO: - do nothing, wait for controller to tell gamescene to create nodes
                if (self.recording) {
                    self.createEyesEmitterNodesWithException(trackingID: face.trackingID, state: self.currentState)
                }
            }
        }
        
    }
    
    func cheeksDetected(face: GMVFaceFeature, state: Int, leftCheekPoint: CGPoint, rightCheekPoint: CGPoint) {
        // cheek
        if (state == -99) {
            
            var randomNum: UInt32 = arc4random_uniform(3)
            var index: Int = Int(randomNum) + 1
            
            if let node = self.childNode(withName: "tid\(face.trackingID)_cheek_left") as! SKSpriteNode? {
                let oldIndex = node.userData?["oldIndex"] as! Int
                let cheekSize: CGSize = oldIndex <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                node.position = leftCheekPoint
            } else {
                var imageNamed = "cheek_"
                if (index == 1)  {
                    imageNamed = "cheek_1_left"
                } else {
                    imageNamed = "cheek_\(index)"
                }
                let node = SKSpriteNode(imageNamed: imageNamed)
                let cheekSize: CGSize = index <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                node.name = "tid\(face.trackingID)_cheek_left"
                node.position = leftCheekPoint
                node.userData = [
                    "oldIndex": index
                ]
                self.addChild(node)
            }
            
            if let node = self.childNode(withName: "tid\(face.trackingID)_cheek_right") as! SKSpriteNode? {
                let oldIndex = node.userData?["oldIndex"] as! Int
                let cheekSize: CGSize = oldIndex <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                node.position = rightCheekPoint
            } else {
                var imageNamed = "cheek_"
                if (index == 1)  {
                    imageNamed = "cheek_1_right"
                } else {
                    imageNamed = "cheek_\(index)"
                }
                let node = SKSpriteNode(imageNamed: imageNamed)
                let cheekSize: CGSize = index <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                node.name = "tid\(face.trackingID)_cheek_right"
                node.userData = [
                    "oldIndex": index
                ]
                node.position = rightCheekPoint
                self.addChild(node)
            }
        } else {
            if let imageNo = KeychainWrapper.standard.integer(forKey: "round") {
                if let node = self.childNode(withName: "tid\(face.trackingID)_cheek_left") as! SKSpriteNode? {
                    if let oldIndex = node.userData?["oldIndex"] as! Int?, oldIndex != imageNo {
                        var imageNamed = "cheek_"
                        if (imageNo == 1)  {
                            imageNamed = "cheek_1_right"
                        } else {
                            imageNamed = "cheek_\(imageNo)"
                        }
                        node.texture = SKTexture(imageNamed: imageNamed)
                        node.userData?["oldIndex"] = imageNo
                    }
                    let cheekSize: CGSize = imageNo <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                    node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                    node.position = leftCheekPoint
                } else {
                    var imageNamed = "cheek_"
                    if (imageNo == 1)  {
                        imageNamed = "cheek_1_left"
                    } else {
                        imageNamed = "cheek_\(imageNo)"
                    }
                    print("imageNamed: \(imageNamed)")
                    let node = SKSpriteNode(imageNamed: imageNamed)
                    let cheekSize: CGSize = imageNo <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                    node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                    node.userData = [
                        "oldIndex": imageNo
                    ]
                    node.name = "tid\(face.trackingID)_cheek_left"
                    node.position = leftCheekPoint
                    self.addChild(node)
                }
                
                if let node = self.childNode(withName: "tid\(face.trackingID)_cheek_right") as! SKSpriteNode? {
                    if let oldIndex = node.userData?["oldIndex"] as! Int?, oldIndex != imageNo {
                        var imageNamed = "cheek_"
                        if (imageNo == 1)  {
                            imageNamed = "cheek_1_right"
                        } else {
                            imageNamed = "cheek_\(imageNo)"
                        }
                        node.texture = SKTexture(imageNamed: imageNamed)
                        node.userData?["oldIndex"] = imageNo
                    }
                    let cheekSize: CGSize = imageNo <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                    node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                    node.position = rightCheekPoint
                } else {
                    var imageNamed = "cheek_"
                    if (imageNo == 1)  {
                        imageNamed = "cheek_1_right"
                    } else {
                        imageNamed = "cheek_\(imageNo)"
                    }
                    print("imageNamed: \(imageNamed)")
                    let node = SKSpriteNode(imageNamed: imageNamed)
                    let cheekSize: CGSize = imageNo <= 2 ? CGSize.init(width: 270.0, height: 188.0) : CGSize.init(width: 230.0, height: 230.0)
                    node.size = CGSize.init(width: (face.bounds.size.width * self.cheekRatio), height: (face.bounds.size.width * self.cheekRatio) * cheekSize.height / cheekSize.width)
                    node.userData = [
                        "oldIndex": imageNo
                    ]
                    node.name = "tid\(face.trackingID)_cheek_right"
                    node.position = rightCheekPoint
                    self.addChild(node)
                }
            }
        }
    }
    
    func faceDetected(face: GMVFaceFeature, center: CGPoint) {
        // sakura face image size, face : 400x520, fullsize: 1163x1086
        // face ratio: 1.3
        // 4.0" -> 0.45, 0.45
        // 4.7" -> 0.48, 0.48
        
        let faceSize = CGSize.init(width: face.bounds.size.height * (400.0 / 520.0), height: face.bounds.size.height)
        let imageSize = CGSize.init(width: faceSize.width * (1163.0 / 400.0) * self.faceMultiplier, height: faceSize.height * (1086.0 / 520.0) * self.faceMultiplier)
        
        if let node = self.childNode(withName: "tid\(face.trackingID)_sakura_face") as! SKSpriteNode? {
            node.size = CGSize.init(width: imageSize.width, height: imageSize.height)
            let faceRotation = self.calculatedFaceRotation(angleY: face.headEulerAngleY, angleZ: face.headEulerAngleZ)
            node.zRotation = faceRotation.zRotation
            // node.xScale = 0.25
            node.position = CGPoint.init(x: center.x + (face.headEulerAngleY / 1.2),y: center.y)
        } else {
            let node = SKSpriteNode(imageNamed: "face_sakura")
            node.name = "tid\(face.trackingID)_sakura_face"
            node.position = center
            node.size = CGSize.init(width: imageSize.width, height: imageSize.height)
            self.addChild(node)
        }
    }
    
    func calculatedFaceRotation(angleY: CGFloat, angleZ: CGFloat) -> (xScale: CGFloat, yScale: CGFloat, zRotation: CGFloat) {
        // print("angleY: \(angleY), angleZ: \(angleZ), \((angleZ * .pi) * 180.0)")
        // zrotation -> z * .pi / 180.0
        let xScale = angleY > 0.0 ? -1.0 * (angleY / 20.0) : angleY / 20.0
        return (xScale + 1.8, 0.0, (angleZ * .pi) / 180.0)
    }
    
    func removeSakuraNode(prefix: UInt) {
        if (self.children.count == 0 || self.mouthEmitterNodes[prefix]?.count == 0) {
            return
        }
        
        self.lockEmitterNodes = true
        
        DispatchQueue.main.async {
            for childNode in self.children {
                if let name = childNode.name, name.contains("tid\(prefix)_sakura_node") {
                    if let node = self.childNode(withName: name) {
                        node.removeFromParent()
                    }
                }
            }
        }
        
        self.lockEmitterNodes = false
    }
    
    func removeAllNode(prefix: UInt) {
        // print("emitter node count: \(self.mouthEmitterNodes[prefix]?.count)")
        
        if (self.children.count == 0 || self.mouthEmitterNodes[prefix]?.count == 0) {
            return
        }
        
        self.lockEmitterNodes = true
        
        DispatchQueue.main.sync {
            for childNode in self.children {
                if let name = childNode.name, name.contains("tid\(prefix)") {
                    // print("name: \(name)")
                    if let node = self.childNode(withName: name) {
                        node.removeFromParent()
                    }
                    // print("success remove node w/ name: \(name)")
                }
            }
            
            if let node = self.childNode(withName: "sound") {
                node.removeFromParent()
            }
        }
        
        //print("remove sound node")
        
        self.lockEmitterNodes = false
        
        //print("remove childNode")
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

    }
    
    func createMouthEmitterNodesWithException(trackingID: UInt, state: Int) {
        
        let settings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(270.0) as AnyObject,
            kEmitterNodeException: true as AnyObject
        ]
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.mouthEmitterNodes[trackingID], state: state, settings: settings)
        
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
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.leftEyeEmitterNodes[trackingID], state: state, settings: lsettings)
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.rightEyeEmitterNodes[trackingID], state: state, settings: rsettings)
        
    }
    
    
    func createEyesEmitterNodesWithException(trackingID: UInt, state: Int) {
        
        let lsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(270.0) as AnyObject,
            kEmitterNodeDirecion: "left" as AnyObject,
            kEmitterNodeException: true as AnyObject
        ]
        
        let rsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(270.0) as AnyObject,
            kEmitterNodeDirecion: "right" as AnyObject,
            kEmitterNodeException: true as AnyObject
        ]
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.leftEyeEmitterNodes[trackingID], state: state, settings: lsettings)
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.rightEyeEmitterNodes[trackingID], state: state, settings: rsettings)
        
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
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.leftEarEmitterNodes[trackingID], state: state, settings: lsettings)
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.rightEarEmitterNodes[trackingID], state: state, settings: rsettings)
        
    }
    
    func createEarsEmitterNodesWithException(trackingID: UInt, state: Int) {
        
        let lsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(180.0) as AnyObject,
            kEmitterNodeDirecion: "left" as AnyObject,
            kEmitterNodeException: true as AnyObject
        ]
        
        let rsettings: Dictionary<String, AnyObject> = [
            kEmitterNodeState: state as AnyObject,
            kEmitterNodeNamePrefix: trackingID as AnyObject,
            kEmitterNodeEmissionAngle: CGFloat(0.0) as AnyObject,
            kEmitterNodeDirecion: "right" as AnyObject,
            kEmitterNodeException: true as AnyObject
        ]
        
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.leftEarEmitterNodes[trackingID], state: state, settings: lsettings)
        SakuraEmitterNodeFactory.sharedInstance.createEmitterNodes(nodes: &self.rightEarEmitterNodes[trackingID], state: state, settings: rsettings)
        
    }
    
    func createSakuraFace(trackingID: UInt) {
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
    
    func removeNode() {
        for node in self.willRemoveNodes {
            node.removeFromParent()
        }
    }
    
}
