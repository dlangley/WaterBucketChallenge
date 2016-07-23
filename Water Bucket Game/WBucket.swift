//
//  WBucket.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/8/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import Foundation

// MARK: - WBucketDelegate

/** Protocol used to update the WBButton */
@objc protocol WBucketDelegate {
    @objc optional func emptyUpdate(_ status: Bool)
    @objc optional func contentUpdate(_ amount: Int)
}


// MARK: - WBucket

/** Model Object for the Water Bucket. */
class WBucket: NSObject {
    
    // MARK: - Setup
    
    /** Don't use this initializer - This may be deleted in the future. */
    override init() {
        super.init()
        content = 0
        capacity = 0
    }
    
    /** Desired initializer. */
    init(withCapacity cap: Int) {
        super.init()
        capacity = cap
        content = 0
    }
    
    
    // MARK: - Properties
    
    /** Reflects the amount of water currently in the bucket.
    * Functional - Updates the WBButton on every change.  Also updates isEmpty and isFull properties.
    */
    var content = 0 {
        willSet {
            isEmpty = newValue == 0
            isFull = newValue == capacity
            delegate?.contentUpdate!(newValue)
        }
    }
    
    /** Reflects the maximum amount of water the bucket can hold. */
    var capacity = 0
    
    /** Returns true if the bucket is empty.
    * Functional - Water bucket will update to reflect this state.
    */
    var isEmpty = true {
        willSet {
            if newValue == !isEmpty {
                delegate?.emptyUpdate!(!newValue)
            }
        }
    }
    
    /** Returns true if the bucket is filled to capacity. */
    var isFull = false
    
    /** Blindly represents any object that will conform to the protocol. */
    weak var delegate : WBucketDelegate?
    
    
    // MARK: - Bucket Action Logic/Calculation
    
    /** Dual Purposed:
    1. Fill bucket if it is not already full.
    2. Return TRUE if action is successful.
    */
    func fill(_ completion: ((successful: Bool)-> Void)) {
        if !isFull {
            content = capacity
            return completion(successful: true)
        }
        return completion(successful: false)
    }
    
    /** Dual Purposed:
    1. Empty bucket if it is not already empty.
    2. Return TRUE if action is successful.
    */
    func dump(_ completion: ((successful: Bool)-> Void)) {
        if !isEmpty {
            content = 0
            return completion(successful: true)
        }
        return completion(successful: false)
    }
    
    /** Dual Purposed:
    1. Add/Subtract a specified non-zero amount of gallons if that amount will not take the bucket beyond capacity or below 0.
    2. Return TRUE if action is successful.
    */
    func take(_ amount: Int, completion: ((successful: Bool)-> Void)) {
        if amount != 0 && 0...capacity ~= content + amount {
            content += amount
            return completion(successful: true)
        }
        return completion(successful: false)
    }
}
