
//
//  WBButton.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/5/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import UIKit

// MARK: Protocol for WBButtoDelegate

/** Protocol used to update WBGameController. */
protocol WBButtonDelegate : class {
    func crossBuckets(_ sender: WBButton) -> (Bool, Int)
    func completeXfer(_ sender: WBButton, amount: Int, completion: @escaping ((_ successful2: Bool)-> Void))
    func moveMade()
}


// MARK: WBButton

/** Custom UIButton used as the Controller and the View for a single Water Bucket. */
class WBButton: UIButton {
    
    /** Model Object for this button. 
     * Functional - Delegate is set upon setting.
     */
    var bucket : WBucket! {
        willSet {
            newValue.delegate = self
        }
    }
    
    var isEmpty = true {
        willSet {
            print("\(bucket.capacity) emptiness is \(newValue)")
        }
    }
    
    var shouldHighlight = false
    
    /** Represents the original location for the bucket to return to after movement. */
    var spot : CGRect!
    
    /** Prevents updating move made twice for 1 xfer. */
    var crossVerified = false
    
    /** Anonymous reference to fire delegate methods. */
    weak var delegate : WBButtonDelegate?
}


// MARK: UIButton LifeCycle Overrides

extension WBButton {
    /** Config the buttons to represent the Water Bucket. */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if bucket == nil {
            bucket = WBucket(with: 0)
        }
        
        titleLabel?.backgroundColor = UIColor.clear
        setBackgroundImage(UIImage(named: "shinyBucket"), for: UIControlState())
        setBackgroundImage(UIImage(named: "shinyFull"), for: UIControlState.selected)
        spot = frame
    }
    
    /** Override to allow for dragging the button. */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if crossVerified {
            crossVerified = false
        }
        
        for touch in touches {
            // Reposition the Button to wherever the finger moves.
            center = touch.location(in: superview)
            
            // Determining animate fill motion when bucket is in the water.
            if center.y >= (superview?.bounds.midY)! && frame.maxY < (superview?.bounds.maxY)! {
                let rAmount = center.y/((superview?.bounds.height)!/2)
                let fromLeft = center.x < (superview?.bounds.midX)!
                transform = CGAffineTransform(rotationAngle: CGFloat(fromLeft ? rAmount : -rAmount))
                
            } else if center.y <= spot.midY {
                
                // animate dump motion when bucket is dragged up or out
                let isLeftBucket = spot.midX <= (superview?.bounds.midX)!
                if isLeftBucket {
                    if frame.minX < (superview?.bounds.minX)! || frame.minY < (superview?.bounds.minY)! {
                        tilt()
                    }
                } else {
                    if frame.maxX > (superview?.bounds.maxX)! || frame.minY < (superview?.bounds.minY)! {
                        tilt()
                    }
                }
            }
        }
    }
    
    /** Override to animate the bounce back and perform the proper bucket action. */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Actions for when the bucket has water in it
        if bucket.content > 0 {
            
            // Constant to reference overlapping bucket info.
            let shouldXfer = delegate!.crossBuckets(self)
            
            // Transfer condition
            if shouldXfer.0 {
                pour(-shouldXfer.1, completion: { (successful) in
                    if successful {
                        self.delegate?.completeXfer(self, amount: shouldXfer.1, completion: { (successful2) in
                            if successful2 {
                                if !self.crossVerified {
                                    self.crossVerified = true
                                    self.delegate?.moveMade()
                                }
                            }
                        })
                    }
                })
            } else if frame.minY <= 0 { // Dump condition
                dump()
            }
        } else if bucket.content < bucket.capacity && frame.midY >= (superview?.bounds.midY)! {
            fill()
        }
        
        // Return button the original position.
        snapToOrigin()
        
        // Update the layout of the view.
        superview!.setNeedsLayout()
    }
}


// MARK: Non-Touch Animations

extension WBButton {
    func snapToOrigin() {
        UIView.animateKeyframes(withDuration: 1/3, delay: 0, options: .beginFromCurrentState, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.frame.origin = self.spot.origin
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4, animations: {
                self.transform = CGAffineTransform(rotationAngle: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 1/8, relativeDuration: 1/16, animations: {
                self.isSelected = !self.isEmpty
            })
        }, completion: { (successful) in
            if self.shouldHighlight {
                self.highlightContent()
            }
        })
    }
    
    /** Spins the title label to alert the player of new values. */
    func highlightContent() {
        UIView.animate(withDuration: 1/5, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.curveEaseInOut] , animations: { () -> Void in
            
            let transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            self.titleLabel?.transform = transform
            
        }) { (finished : Bool) -> Void in
            
            let trans = CGAffineTransform(rotationAngle: 0)
            self.titleLabel?.transform = trans
        }
        shouldHighlight = false
    }
    
    /** Rotates the button to dump water. */
    func tilt() {
        let fromLeft = center.x < (superview?.bounds.midX)!
        let s = frame.minX/((superview?.bounds.width)!/2)
        let t = frame.minY/((superview?.bounds.height)!/2)
        let rAmount = abs(s + t)
        transform = CGAffineTransform(rotationAngle: CGFloat(fromLeft ? -rAmount : rAmount))
        setNeedsLayout()
    }
}


// MARK: Bucket Actions

extension WBButton {
    /** Empties the contents of the bucket. */
    func dump() {
        guard !isEmpty else {
            print("Bucket already empty.")
            return
        }
        
        do {
            try bucket.load(-bucket.content)
        } catch {
            print("Check Bucket Problem Error Cases")
            return
        }
        self.delegate?.moveMade()
    }
    
    /** Fills the bucket. */
    func fill() {
        do {
            try bucket.load(bucket.room)
        } catch {
            print("Check Bucket Problem Error Cases")
            return
        }
        self.delegate?.moveMade()
    }
    
    /** Adds a specified amount of gallons to the bucket. */
    func pour(_ amount: Int, completion: @escaping ((_ successful: Bool)-> Void)) {
        do {
            try bucket.load(amount)
        } catch {
            print("Check Bucket Problem Error Cases")
            return completion(false)
        }
        return completion(true)
    }
}


// MARK: WBucketDelegate Methods

extension WBButton: WBucketDelegate {
    /// Updates the button title with the current amount.
    func contentUpdate(_ amount: Int) {
        shouldHighlight = true
        setTitle( "\(amount)", for: UIControlState())
        setTitle( "\(amount)", for: UIControlState.selected)
        setTitle( "\(amount)", for: UIControlState.highlighted)
        isEmpty = amount == 0
    }
}
