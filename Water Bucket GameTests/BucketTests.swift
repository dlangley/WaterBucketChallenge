//
//  BucketTests.swift
//  Water Bucket GameTests
//
//  Created by Dwayne Langley on 9/25/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import XCTest
@testable import Water_Bucket_Game

class BucketTests: XCTestCase {
    
    var bucket = WBucket(with: 3)
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBucketIntake() {
        // Error when attempting to put no water in the bucket.
        XCTAssert(canTake(0) != nil, canTake(0)!)
        // Error when attempting to fill bucket to less than 0 gallons.
        XCTAssert(canTake(-5) != nil, canTake(-5)!)
        // Error when attempting to overflow the bucket.
        XCTAssert(canTake(10) != nil, canTake(10)!)
        // No error for any amount the bucket can hold.
        XCTAssert(canTake(2) == nil, "Added \(2) to \(bucket.content) in a bucket that holds \(bucket.capacity).")
    }
    
    /// Utility method to execute and return feedback for the test.
    fileprivate func canTake(_ amount: Int) -> String? {
        // Gives proper response for a particular amount.
        do {
            try bucket.load(amount)
        } catch {
            return "Bucket Problem: \(error)"
        }
        
        return nil
    }
    
}
