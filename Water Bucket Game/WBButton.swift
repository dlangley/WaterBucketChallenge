//
//  WBButton.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/5/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import UIKit

// MARK: - WBButton

/** Custom UIButton used as the Controller and the View for a single Water Bucket. */
class WBButton: UIButton, WBucketDelegate {

    // MARK: - Properties
    
    /** Model Object for this button. 
    * Functional - Delegate is set upon setting.
    */
    var bucket : WBucket! {
        willSet {
            newValue.delegate = self
        }
    }
    
    /** Represents the original location for the bucket to return to after movement. */
    var spot : CGRect!
    
    
    // MARK: - UIButton LifeCycle Methods
    
    /** Config the buttons to represent the Water Bucket. */
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if bucket == nil {
            bucket = WBucket()
        }
        
        setBackgroundImage(UIImage(named: "shinyBucket"), forState: UIControlState.Normal)
        setBackgroundImage(UIImage(named: "shinyFull"), forState: UIControlState.Selected)
        spot = frame
    }
    
    /** Override to allow for dragging the button. */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        for touch in touches {
            center = touch.locationInView(superview)
        }
    }
    
    
    // MARK: - WBucketDelegate Methods
    
    /** Updates the button title with the current amount. */
    func contentUpdate(amount: Int) {
        setTitle( "\(amount)", forState: UIControlState.Normal)
        setTitle( "\(amount)", forState: UIControlState.Selected)
        setTitle( "\(amount)", forState: UIControlState.Highlighted)
        setNeedsDisplay()
    }
    
    /** Updates the button image with the presesnce/absence of water. */
    func emptyUpdate(status: Bool) {
        selected = status
    }
}