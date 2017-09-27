//
//  Game.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/6/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import Foundation

// MARK: - Global Constants

/** Global constant referencing the Game Singleton Instance.*/
let game = Game.sharedGame


// MARK: - GameDelegate

/** Protocol used to update WBGameController. */
@objc protocol GameDelegate {
    func gameStatusChanged(_ iValue : Int)
}


// MARK: - Game

/** The main model class driving the game states and functions. */
class Game : NSObject {
    
    /** Iniitializer for the game. */
    required override init() {
        super.init()
        
        configure {}
    }
    
    /** Singleton instance of the Game class.*/
    static let sharedGame = Game()
    
    /** The blind delegate declaration - could be any object. */
    weak var delegate : GameDelegate?
    
    /** Values for setting the Bucket Capacities, Target Amount, and Game time.*/
    var bucket1, bucket2, target, time : Int!

    
    // TODO: - AI to measure efficiency of the player's solution.
    
    /** Game states to let the app know when you've solved the puzzle.
     * Functional - Initiates corresponding actions.
     */
    var status : state = .ready {
        willSet {
            delegate?.gameStatusChanged(newValue.rawValue)
        }
    }
    
    /** A list of the possible game states.*/
    enum state : Int {
        case ready = 0, finished, solved, failed
    }
    
    /** Sets the game environment.
     * Uses default values for optional parameters.
     * Provides a completion block
     */
    func configure(_ buc1: Int? = 3, buc2: Int? = 5, targ: Int? = 4, t: Int? = 30, completion:(() -> Void)) {
        
        if isSolvable(buc1, cap2: buc2, targ: targ) {
            bucket1 = buc1 ?? bucket1
            bucket2 = buc2 ?? bucket2
            target = targ ?? target
            time = t ?? time
        }
        
        status = .ready
    }
    
    /** Evaluates true if the combination of buckets and targets are solvable.*/
    func isSolvable(_ cap1 : Int?, cap2 : Int?, targ: Int?) -> Bool {
        if let c1 = cap1, let c2 = cap2, let t = targ {
            let evenBucketsOddTargets = c1 % 2 == 0 && c2 % 2 == 0 && t % 2 != 0
            let sameBuckets = c1 == c2 && c1 != t
            return !evenBucketsOddTargets && !sameBuckets
        }
        return false
    }
}
