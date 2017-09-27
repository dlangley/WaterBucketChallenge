//
//  WBucket.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/8/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import Foundation

// MARK: - WBucketDelegate
/// Protocol used to update the WBButton.
@objc protocol WBucketDelegate {
    @objc optional func contentUpdate(_ amount: Int)
}


// MARK: - WBucket
/// Model Object for the Water Bucket.
class WBucket: NSObject {
    
    // MARK: - Setup
    /// Creates a new bucket with a specified capacity.
    init(with capacity: Int) {
        super.init()
        self.capacity = capacity
        content = 0
    }
    
    // MARK: - Properties
    /** Reflects the amount of water currently in the bucket.
    * Functional - Updates the WBButton on every change.
    */
    var content = 0 {
        willSet {
            delegate?.contentUpdate!(newValue)
        }
    }
    
    /// Reflects the maximum amount of water the bucket can hold.
    var capacity = 0
    
    /// Calculates how many gallons we can add to this bucket
    var room : Int {
        return capacity - content
    }
    
    /// Blindly represents any object that will conform to the protocol.
    weak var delegate : WBucketDelegate?
    
    /// Errors that can occur in the course of performing bucket actions.
    enum Problem: String, Error {
        case negativeAmount, bucketOverflow, noWaterAction
    }

    // MARK: - Bucket Actions Logic/Calculation
    /// Add/Subtract a specified non-zero amount of gallons if that amount will not take the bucket beyond capacity or below 0.
    func load(_ amount: Int) throws {
        
        // Error when adding 0 gallons.
        guard amount != 0 else {
            throw Problem.noWaterAction
        }
        
        let result = content + amount
        
        // Verify that the resulting amount of water fits within this bucket.
        guard 0...capacity ~= result else {
            
            // Error on negative amount of water.
            guard result > 0 else {
                throw Problem.negativeAmount
            }
            
            // Error on too much water for the bucket.
            throw Problem.bucketOverflow
        }
        
        // No errors... Add the water.
        content = result
    }
}
