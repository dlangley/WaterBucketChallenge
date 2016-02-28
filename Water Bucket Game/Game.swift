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
@objc protocol GameDelegate {
    func gameStatusChanged(iValue : Int)
}


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
    
    /** Singleton instance of the Game class.*/
    weak var delegate : GameDelegate?
    
    /** Values for setting the Bucket Capacities and Target Amount.*/
    var bucket1, bucket2, target : Int!
    
    // TODO: - Menu to allow the user to set the variables.
    // TODO: - AI to measure efficiency of the player's solution.
    // TODO: - Implement Game states to let the app know when you've solved the puzzle.
    
    var status : state = .ready {
        willSet {
            switch newValue {
            case .ready: fallthrough
            case .solved:
                delegate?.gameStatusChanged(newValue.rawValue)
            case .failed: fallthrough
            default: break
            }
        }
    }
    
    /** A list of the possible game states.*/
    enum state : Int {
        case ready = 0, finished, solved, failed
    }
}

/** Global constant referencing Singleton.*/
let game = Game.sharedGame