//
//  WBomb.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 10/10/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

protocol BombLogic: class {
    func elapsed(to time: Int)
}

/// Model Object for the Bomb.
class WBomb: NSObject {
    
    /// Creates a new bucket with a specified capacity.
    init(with trigger: Int, and time: Int) {
        super.init()
        
        setTriggers(trigger, time)
    }
    
    // MARK: - Properties
    weak var delegate: BombLogic?
    
    /// The required amount of pressure to diffuse the Bomb.
    var diffuseTrigger = 0
    
    /** The current amount of pressure on bomb.
     * Functional - Triggers Success or Failure event, disarms the bomb.
     */
    private var pressure = 0 {
        willSet {
            guard newValue > 0 else { return }
            if isArmed {
                isArmed = false
            }
        }
    }
    
    /** Remaining time in the game.
     * Functional - Updates the delegate.
     */
    private var timeLimit = 0 {
        willSet {
            DispatchQueue.main.async {
                self.delegate?.elapsed(to: newValue)
            }
            if newValue == 0 {
                isArmed = false
            }
        }
    }
    
    /** Returns true if the bomb is armed.
     * Functional - Starts & Stops the countdown.
     */
    var isArmed = false {
        willSet {
            guard newValue else {
                timer.invalidate()
                pressure = 0
                return
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.timeLimit = self.timeLimit - 1
            })
        }
    }
    
    /** Timer to drive the countdown for the Bomb. */
    private var timer = Timer()
    
    /// Errors that can occur in the course of performing bucket actions.
    enum Problem: String, Error {
        case noDiffuser, noTime, triggeredExplosion
    }
    
    /// Arms the bomb to start the timer.
    func arm() throws {
        guard timeLimit > 0 else {
            throw Problem.noTime
        }
        guard diffuseTrigger > 0 else {
            throw Problem.noDiffuser
        }
        isArmed = true
    }
    
    /// Disarms the bomb for success or failure.
    func disarm(with waterPressure: Int) throws {
        guard waterPressure == diffuseTrigger else {
            throw Problem.triggeredExplosion
        }
        pressure = waterPressure
    }
}

// MARK: - Bomb Methods
extension WBomb {
    
    /// Sets the necessary variables.
    fileprivate func setTriggers(_ trigger: Int, _ time: Int) {
        diffuseTrigger = trigger
        timeLimit = time
        pressure = 0
    }
}
