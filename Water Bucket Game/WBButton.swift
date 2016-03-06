//
//  WBButton.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/5/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import UIKit

// MARK: - WBButtonDelegate

/** Protocol used to update WBGameController. */
protocol WBButtonDelegate : class {
    func crossBuckets(sender: WBButton) -> (Bool, Int)
    func completeXfer(sender: WBButton, amount: Int) -> Bool
    func moveMade()
}


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
    
    weak var delegate : WBButtonDelegate?
    
    
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
            // Reposition the Button to wherever the finger moves.
            center = touch.locationInView(superview)
            
            // Determining animate fill motion when bucket is in the water.
            if center.y >= superview?.bounds.midY && frame.maxY < superview?.bounds.maxY {
                let rAmount = center.y/((superview?.bounds.height)!/2)
                let fromLeft = center.x < superview?.bounds.midX
                transform = CGAffineTransformMakeRotation(CGFloat(fromLeft ? rAmount : -rAmount))
            
            } else if center.y <= spot.midY {
                
                // animate dump motion when bucket is dragged up or out
                let isLeftBucket = spot.midX <= superview?.bounds.midX
                if isLeftBucket {
                    if frame.minX < superview?.bounds.minX || frame.minY < superview?.bounds.minY {
                        tilt()
                    }
                } else {
                    if frame.maxX > superview?.bounds.maxX || frame.minY < superview?.bounds.minY {
                        tilt()
                    }
                }
            }
        }
    }
    
    /** Override to animate the bounce back and perform bucket actions. */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        // Perform the proper bucket action.
        if let shouldXfer = delegate?.crossBuckets(self) {
            if shouldXfer.0 {
                xfer(shouldXfer.1)
            } else if frame.midY >= superview?.bounds.midY {
                fill()
            } else if frame.minY <= 0 {
                dump()
            }
        }
        
        // Return button the original position.
        UIView.animateWithDuration(0.25) { () -> Void in
            self.frame.origin = self.spot.origin
            self.transform = CGAffineTransformMakeRotation(0)
        }
        
        // Update the layout of the view.
        superview!.setNeedsLayout()
    }
    
    
    // MARK: - Other Animations
    
    /** Spins the title label to alert the player of new values. */
    func highlightContent() {
        UIView.animateWithDuration(0.25, delay: 0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.CurveEaseInOut] , animations: { () -> Void in
            
            let transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            self.titleLabel?.transform = transform
            
            }) { (finished : Bool) -> Void in
                
                let trans = CGAffineTransformMakeRotation(0)
                self.titleLabel?.transform = trans
        }
    }
    
    /** Rotates the button to dump water. */
    func tilt() {
        let fromLeft = center.x < superview?.bounds.midX
        let s = frame.minX/((superview?.bounds.width)!/2)
        let t = frame.minY/((superview?.bounds.height)!/2)
        let rAmount = abs(s + t)
        transform = CGAffineTransformMakeRotation(CGFloat(fromLeft ? -rAmount : rAmount))
        setNeedsLayout()
    }
    
    
    // MARK: - Bucket Actions
    
    /** Empties the bucket. */
    func dump() {
        if bucket.empty() {
            delegate?.moveMade()
        }
    }
    
    /** Fills the bucket. */
    func fill() {
        if bucket.fill() {
            delegate?.moveMade()
        }
    }
    
    /** Transfers water from this bucket to the next. */
    func xfer(amount: Int) {
        if bucket.take(-amount) {
            if let _ = delegate?.completeXfer(self, amount: amount) {
                delegate?.moveMade()
            }
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