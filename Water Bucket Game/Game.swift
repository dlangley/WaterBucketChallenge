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
    func gameStatusChanged(iValue : Int)
    func timeChanged(remainingTime : Int)
}


// MARK: - Game

/** The main model class driving the game states and functions. */
class Game : NSObject {
    
    /** Iniitializer for the game. */
    required override init() {
        super.init()
        
        config()
    }
    
    /** Singleton instance of the Game class.*/
    static let sharedGame = Game()
    
    /** The blind delegate declaration - could be any object. */
    weak var delegate : GameDelegate?
    
    /** Values for setting the Bucket Capacities, Target Amount, and Game time.*/
    var bucket1, bucket2, target, time : Int!
    
    /** Remaining time in the game. 
    * Functional - Updates the game controller with the remaining time.
    */
    private var remaining : Int! {
        willSet {
            delegate?.timeChanged(newValue)
        }
    }
    
    /** Timer for game functions. */
    var timer : NSTimer!
    
    // TODO: - AI to measure efficiency of the player's solution.
    
    /** Game states to let the app know when you've solved the puzzle. 
    * Functional - Initiates corresponding actions.
    */
    var status : state = .ready {
        willSet {
            switch newValue {
            case .solved: fallthrough
            case .failed:
                timer.invalidate()
            case .ready:
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
            default: break
            }
            delegate?.gameStatusChanged(newValue.rawValue)
        }
    }
    
    /** A list of the possible game states.*/
    enum state : Int {
        case ready = 0, finished, solved, failed
    }
    
    /** Decrements the remaining time. */
    func countDown() {
        remaining = remaining - 1
    }
    
    /** Sets the game environment. 
    * Uses default values for optional parameters.
    */
    func config(buc1: Int? = 3, buc2: Int? = 5, targ: Int? = 4, t: Int? = 30) {
        bucket1 = buc1 ?? bucket1
        bucket2 = buc2 ?? bucket2
        target = targ ?? target
        time = t ?? time
        remaining = time
        
        status = .ready
    }
}