//
//  WBomb.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 10/10/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

protocol BombLogic: class {
    func diffuseAttempt(successful: Bool)
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
    * Functional - Triggers Success or Failure event.
    */
    private var pressure = 0 {
        willSet {
            if let ticker = timer {
                ticker.invalidate()
            }
            guard newValue == diffuseTrigger else {
                delegate?.diffuseAttempt(successful: false)
                return
            }
            delegate?.diffuseAttempt(successful: true)
        }
    }
    
    /** Remaining time in the game.
     * Functional - Updates the delegate.
     */
    private var timeTrigger = 0 {
        willSet {
            DispatchQueue.main.async {
                self.delegate?.elapsed(to: newValue)
            }
            if newValue == 0 {
                timer.invalidate()
            }
        }
    }
    
    /** Timer to drive the countdown for the Bomb. */
    private var timer : Timer!
}

// MARK: - Bomb Methods
extension WBomb {
    /// Starts the timer.
    func setItOff() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.timeTrigger = self.timeTrigger - 1
        })
    }
    
    /// Sets the necessary variables.
    fileprivate func setTriggers(_ trigger: Int, _ time: Int) {
        diffuseTrigger = trigger
        timeTrigger = time
        pressure = 0
    }
}
