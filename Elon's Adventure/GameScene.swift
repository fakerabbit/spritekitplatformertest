//
//  GameScene.swift
//  Elon's Adventure
//
//  Created by Mirko Justiniano on 9/22/19.
//  Copyright © 2019 idevcode. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: Variables
    
    // Nodes
    var player: SKNode?,
        joystick: SKNode?,
        joystickKnob: SKNode?,
        cameraNode: SKCameraNode?,
        mountains1: SKNode?,
        mountains2: SKNode?,
        mountains3: SKNode?,
        moon: SKNode?,
        stars: SKNode?
    
    var joystickAction = false,
        knobRadius: CGFloat = 50.0
    
    // Sprite Engine
    var previousTimeInterval: TimeInterval = 0,
        playerIsFacingRight = true
    let playerSpeed = 4.0
    
    // Player State
    var playerStateMachine: GKStateMachine!
    
    // MARK: Methods
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        player = childNode(withName: "player")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        mountains1 = childNode(withName: "mountains1")
        mountains2 = childNode(withName: "mountains2")
        mountains3 = childNode(withName: "mountains3")
        moon = childNode(withName: "moon")
        stars = childNode(withName: "stars")
        
        playerStateMachine = GKStateMachine(states: [
            JumpingState(playerNode: player!),
            WalkingState(playerNode: player!),
            IdleState(playerNode: player!),
            LandingState(playerNode: player!),
            StunnedState(playerNode: player!)
        ])
        playerStateMachine.enter(IdleState.self)
        
        // Timer
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            self.spawnMeteor()
        }
    }
}

// MARK:- Touches
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            let location = touch.location(in: self)
            if !(joystick?.contains(location))! {
                playerStateMachine.enter(JumpingState.self)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        if !joystickAction { return }
        for touch in touches {
            let position = touch.location(in: joystick)
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200.0
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
        }
    }
}

// MARK:- Actions
extension GameScene {
    
    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
}

// MARK:- Game Loop
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        // Camera
        cameraNode?.position.x = player!.position.x
        joystick?.position.y = (cameraNode!.position.y) - 100
        joystick?.position.x = (cameraNode!.position.x) - 300
        
        // Player Movement
        guard let joystickKnob = joystickKnob else { return }
        guard let player = player else { return }
        let xPosition = Double(joystickKnob.position.x)
        let positivePosition = xPosition < 0 ? -xPosition : xPosition
        
        if floor(positivePosition) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        
        let faceAction: SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
        if movingLeft && playerIsFacingRight {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1, duration: 0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1, duration: 0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else {
            faceAction = move
        }
        player.run(faceAction)
        
        // Background Parallax
        let parallax1 = SKAction.moveTo(x: player.position.x/(-10), duration: 0)
        mountains1?.run(parallax1)
        
        let parallax2 = SKAction.moveTo(x: player.position.x/(-20), duration: 0)
        mountains2?.run(parallax2)
        
        let parallax3 = SKAction.moveTo(x: player.position.x/(-40), duration: 0)
        mountains3?.run(parallax3)
        
        let parallax4 = SKAction.moveTo(x: cameraNode!.position.x, duration: 0)
        moon?.run(parallax4)
        
        let parallax5 = SKAction.moveTo(x: cameraNode!.position.x, duration: 0)
        stars?.run(parallax5)
    }
}

// MARK:- Collision
extension GameScene: SKPhysicsContactDelegate {
    
    struct Collision {
        enum Masks: Int {
            case killing, player, reward, ground
            var bitmask: UInt32 { return 1 << self.rawValue }
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches(_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) ||
            (first.bitmask == masks.second && second.bitmask == masks.first)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing) {
            let die = SKAction.move(to: CGPoint(x: -300, y: -100), duration: 0)
            player?.run(die)
        }
        
        if collision.matches(.player, .ground) {
            playerStateMachine.enter(LandingState.self)
        }
        
        if collision.matches(.ground, .killing) {
            if contact.bodyA.node?.name == "Meteor", let meteor = contact.bodyA.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            if contact.bodyB.node?.name == "Meteor", let meteor = contact.bodyB.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
        }
    }
}

// MARK:- Other Elements
extension GameScene {
    
    func spawnMeteor() {
        
        let node = SKSpriteNode(imageNamed: "meteor")
        node.name = "Meteor"
        let randomXPosition = Int(arc4random_uniform(UInt32(self.size.width)))
        
        node.position = CGPoint(x: randomXPosition, y: 270)
        node.anchorPoint = CGPoint(x: 0.5, y: 1)
        node.zPosition = 5
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 30)
        node.physicsBody = physicsBody
        
        physicsBody.categoryBitMask = Collision.Masks.killing.bitmask
        physicsBody.collisionBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physicsBody.contactTestBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physicsBody.fieldBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = false
        physicsBody.restitution = 0.2
        physicsBody.friction = 10
        
        addChild(node)
    }
    
    func createMolten(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "molten")
        node.position.x = position.x
        node.position.y = position.y - 90
        node.zPosition = 4
        
        addChild(node)
        
        let action = SKAction.sequence([
            .fadeIn(withDuration: 0.1),
            .wait(forDuration: 3),
            .fadeOut(withDuration: 0.2),
            .removeFromParent()
        ])
        node.run(action)
    }
}

