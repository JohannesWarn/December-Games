//
//  GameScene.swift
//  Chain Pop
//
//  Created by Johannes Wärn on 05/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

import SpriteKit

enum CollisionCategory : UInt32 {
    case Wall = 1
    case Bubble = 2
    case Bomb = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0.0, -0.1)
        physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        physicsBody?.categoryBitMask = CollisionCategory.Wall.rawValue
        physicsBody?.collisionBitMask = CollisionCategory.Bubble.rawValue
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 1.0
        
        var noise = SKFieldNode.noiseFieldWithSmoothness(1.0, animationSpeed: 1.0)
        noise.strength = 0.0002
        self.addChild(noise)
        
        for n in 0 ..< 25 {
            addBubble()
        }
    }
    
    func addBubble(animated : Bool = false) {
        let bubble = Bubble()
        addChild(bubble)
        bubble.position = CGPoint(
            x: bubble.radius * 2 + (self.size.width  - bubble.radius) * CGFloat(randomDouble()),
            y: bubble.radius * 2 + (self.size.height - bubble.radius) * CGFloat(randomDouble())
        )
        if animated {
            bubble.xScale = 0
            bubble.yScale = bubble.xScale
            bubble.runAction(SKAction.scaleTo(1, duration: 0.5))
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches.allObjects as [UITouch] {
            let bomb = Bomb()
            addChild(bomb)
            bomb.position = touch.locationInNode(self)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let bubble = contact.bodyA.node as? Bubble {
            if let bomb = contact.bodyB.node as? Bomb {
                let remove = SKAction.sequence([
                    SKAction.fadeAlphaTo(0, duration: 0.9),
                    SKAction.removeFromParent()
                    ])
                
                bomb.removeActionForKey("grow")
                
                if (bubble.kind == 0) {
                    self.runAction(SKAction.playSoundFileNamed("ljud3.caf", waitForCompletion: false))
                } else if (bubble.kind == 1) {
                    self.runAction(SKAction.playSoundFileNamed("ljud4.caf", waitForCompletion: false))
                } else if (bubble.kind == 2) {
                    self.runAction(SKAction.playSoundFileNamed("ljud5.caf", waitForCompletion: false))
                } else if (bubble.kind == 3) {
                    self.runAction(SKAction.playSoundFileNamed("ljud6.caf", waitForCompletion: false))
                } else {
                    self.runAction(SKAction.playSoundFileNamed("ljud7.caf", waitForCompletion: false))
                }
                bomb.runAction(remove)
            }
        }
    }
}

class Bubble: SKShapeNode {
    let radius: CGFloat = 5.0
    let possibleKinds = 5
    let kind: Int
    let color: SKColor
    
    override init() {
        kind = Int(arc4random()) % possibleKinds
        let hue = fmod(-0.04 + 1.0 / Double(possibleKinds) * Double(kind), 1.0 + randomDouble() * 0.6)
        let saturation = 0.58 + randomDouble() * 0.1
        let brightness = 0.75 + randomDouble() * 0.1
        color = SKColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1.0)
        
        super.init()
        path = CGPathCreateWithEllipseInRect(CGRectMake(-radius, -radius, radius * 2, radius * 2), nil)
        fillColor = color
        strokeColor = color
        name = "bubble"
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask = CollisionCategory.Bubble.rawValue
        physicsBody?.collisionBitMask = CollisionCategory.Bubble.rawValue | CollisionCategory.Wall.rawValue
        physicsBody?.contactTestBitMask = CollisionCategory.Bomb.rawValue
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.friction = 0.0
        let angle = CGFloat(randomDouble() * M_PI)
        let magnitude = CGFloat(randomDouble() * 50 + 30)
        physicsBody?.velocity = CGVectorMake(cos(angle) * magnitude, sin(angle) * magnitude)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Bomb: SKShapeNode {
    var kind: Int?
    var radius: CGFloat = 1.0
    var bubblesKilled : Int = 0
    
    override init() {
        super.init()
        path = CGPathCreateWithEllipseInRect(CGRectMake(-radius, -radius, radius * 2, radius * 2), nil)
        let color = SKColor(white: 1.0, alpha: 0.15)
        fillColor = color
        strokeColor = SKColor.clearColor()
        name = "bomb"
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask = CollisionCategory.Bomb.rawValue
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 0
        physicsBody?.allowsRotation = false
        physicsBody?.pinned = true
        
        let grow = SKAction.runBlock {
            [unowned self] () -> () in
            self.radius += 1.0
            self.path = CGPathCreateWithEllipseInRect(CGRectMake(-self.radius, -self.radius, self.radius * 2, self.radius * 2), nil)
            self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
            self.physicsBody?.categoryBitMask = CollisionCategory.Bomb.rawValue
            self.physicsBody?.collisionBitMask = 0
            self.physicsBody?.contactTestBitMask = 0
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.pinned = true
        }
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(1.0 / 60), grow])), withKey: "grow")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func randomDouble() -> Double {
    return Double(arc4random()) / Double(UINT32_MAX)
}