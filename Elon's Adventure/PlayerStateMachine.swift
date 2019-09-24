//
//  PlayerStateMachine.swift
//  Elon's Adventure
//
//  Created by Mirko Justiniano on 9/23/19.
//  Copyright © 2019 idevcode. All rights reserved.
//

import Foundation
import GameplayKit

fileprivate let characterAnimationKey = "Sprite Animation"

class PlayerState: GKState {
    unowned var playerNode: SKNode
    
    init(playerNode: SKNode) {
        self.playerNode = playerNode
        
        super.init()
    }
}

class JumpingState: PlayerState {
    var hasFinishedJumping: Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        hasFinishedJumping = false
        //playerNode.run(.applyForce(CGVector(dx: 0, dy: 75), duration: 0.1))
        let jumpAction = SKAction.applyImpulse(CGVector(dx: 0, dy: 35), duration: 0.1)
        playerNode.run(jumpAction)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.hasFinishedJumping = true
        }
    }
}
