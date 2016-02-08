//
//  Game.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/6/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import Foundation

// MARK: - Game

/** Pure Swift class. (Does not need inheritance from NSObject)*/
class Game {
    
    /** Iniitializer for the game.
    * Currently hardcodes the Bucket and Target values.
    */
    required init() {
        bucket1 = 3
        bucket2 = 5
        target = 4
    }
    
    /** Singleton instance of the Game class.*/
    static let sharedGame = Game()
    
    /** Temporary Model Object.*/
    var bucket1, bucket2, target : Int!
    
    // TODO: - Menu to allow the user to set the variables.
    // TODO: - AI to measure efficiency of the player's solution.
    // TODO: - Implement Game states to let the app know when you've solved the puzzle.
}

/** Global constant referencing Singleton.*/
let game = Game.sharedGame