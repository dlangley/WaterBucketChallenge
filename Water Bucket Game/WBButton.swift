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
        titleLabel?.backgroundColor = UIColor.clearColor()
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
    
    /** Override to automate the bounce back. */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.frame.origin = self.spot.origin
        }
    }
    
    // MARK: - Other Animations
    func highlightContent() {
        UIView.animateWithDuration(0.25, delay: 0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.CurveEaseInOut] , animations: { () -> Void in
            
            let transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            self.titleLabel?.transform = transform
            
            }) { (finished : Bool) -> Void in
                
                let trans = CGAffineTransformMakeRotation(0)
                self.titleLabel?.transform = trans
        }
    }
    
    // MARK: - WBucketDelegate Methods
    
    /** Updates the button title with the current amount. */
    func contentUpdate(amount: Int) {
        setTitle( "\(amount)", forState: UIControlState.Normal)
        setTitle( "\(amount)", forState: UIControlState.Selected)
        setTitle( "\(amount)", forState: UIControlState.Highlighted)
        highlightContent()
    }
    
    /** Updates the button image with the presesnce/absence of water. */
    func emptyUpdate(status: Bool) {
        selected = status
    }
}