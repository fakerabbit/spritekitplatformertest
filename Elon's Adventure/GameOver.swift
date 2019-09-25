//
//  GameOver.swift
//  Elon's Adventure
//
//  Created by Mirko Justiniano on 9/24/19.
//  Copyright © 2019 idevcode. All rights reserved.
//

import Foundation
import SpriteKit

class GameOver: SKScene {
    
    override func sceneDidLoad() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            let level1 = Level1(fileNamed: "Level1")
            self.view?.presentScene(level1)
            self.removeAllActions()
        }
    }
}
