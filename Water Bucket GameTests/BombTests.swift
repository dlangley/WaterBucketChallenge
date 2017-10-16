//
//  BombTests.swift
//  Water Bucket GameTests
//
//  Created by Dwayne Langley on 10/13/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import XCTest
@testable import Water_Bucket_Game

class BombTests: XCTestCase {
    
    var bomb : WBomb!
    
    override func setUp() {
        super.setUp()
        
        // By default, the bomb will be set with a pressure trigger of 4 and a time limit of 30 seconds.
        bomb = WBomb(with: 4, and: 30)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArmingPreconditions() {
        
        // Exception for attempt to arm a bomb with no time limit.
        XCTAssert(canArm(for: 4, at : 0) != nil, canArm(for: 4, at : 0)!)
        // Exception for attempt to arm a bomb with no diffuse trigger.
        XCTAssert(canArm(for: 0, at : 4) != nil, canArm(for: 0, at : 4)!)
        // No Exception with a proper time limit & diffuse trugger.
        XCTAssert(canArm() == nil, "No errors for the correct bomb environment!")
    }
    
    func testDisarmingPreconditions() {
        // Exception for attempt to disarm a bomb with a lesser pressure.
        XCTAssert(canDisarm(with: 3) != nil, canDisarm(with: 3)!)
        // Exception for attempt to disarm a bomb with a greater pressure.
        XCTAssert(canDisarm(with: 5) != nil, canDisarm(with: 5)!)
        // No Exception for attempt to disarm a bomb with correct pressure.
        XCTAssert(canDisarm(with: 4) == nil, "No erors for the correct amount of pressure.")
    }
    
    fileprivate func canArm(for trigger: Int = 4, at time: Int = 1) -> String? {
        bomb = WBomb(with: trigger, and: time)
        
        do {
            try bomb.arm()
        } catch {
            return "Can't Arm Bomb: \(error)"
        }
        
        return nil
    }
    
    fileprivate func canDisarm(with pressure: Int) -> String? {
        do {
            try bomb.disarm(with: pressure)
        } catch {
            return "Can't Arm Bomb: \(error)"
        }
        
        return nil
    }
}
