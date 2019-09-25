//
//  Sound.swift
//  Elon's Adventure
//
//  Created by Mirko Justiniano on 9/24/19.
//  Copyright © 2019 idevcode. All rights reserved.
//

import Foundation
import SpriteKit

enum Sound: String {
    case hit, jump, levelUp, meteorFalling, reward
    
    var action: SKAction {
        return SKAction.playSoundFileNamed(rawValue + "Sound.wav", waitForCompletion: false)
    }
}

extension SKAction {
    static let playGameMusic: SKAction = playSoundFileNamed("music.wav", waitForCompletion: false)
}
