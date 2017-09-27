
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
    
    /// Represents the original location for the bucket to return to after movement.
    var spot : CGRect!
    
    /// True when there is no water in the bucket.
    var isEmpty = true 
    
    /// True when the user needs to be updated about a change in the bucket contents.
    var shouldHighlight = false
    
    /// True when you've dropped this bucket onto another bucket.
    var crossVerified = false
    
    /// Computed by the starting position of the bucket.
    var isLeftBucket : Bool {
        return spot.midX <= (superview?.bounds.midX)!
    }
    
    /// Anonymous reference to fire delegate methods.
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
        
        // Constant to reference overlapping bucket info.
        let shouldXfer = delegate!.crossBuckets(self)
        
        if bucket.content > 0 && shouldXfer.0 { // Transfer condition
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
        } else if frame.midY >= (superview?.bounds.midY)! { // Fill Condition
            fill()
        }
        
        snapToOrigin()
        
        // Update the layout of the view.
        superview!.setNeedsLayout()
    }
}


// MARK: Non-Touch Animations

extension WBButton {
    
    /// Returns the button to it's original position and orientation.
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
    
    /// Spins the title label to deliver feedback of new water levels.
    func highlightContent() {
        
        // Setup constants to use in animations
        let transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        // Do the animation
        UIView.animateKeyframes(withDuration: 1/5, delay: 0, options: [.autoreverse, .calculationModePaced], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.titleLabel?.transform = transform
            })
        }) { (isFinished) in // Clean up the animation
            let trans = CGAffineTransform(rotationAngle: 0)
            self.titleLabel?.transform = trans
        }
        
        // Clean up feedback logic
        shouldHighlight = false
    }
    
    /// Rotates the button to dump water.
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
        do {
            try bucket.load(-bucket.content)
        } catch {
            print("Bucket Problem: \(error)")
            return
        }
        self.delegate?.moveMade()
    }
    
    /** Fills the bucket. */
    func fill() {
        do { try bucket.load(bucket.room) }
        catch {
            print("Bucket Problem: \(error)")
            return
        }
        self.delegate?.moveMade()
    }
    
    /** Adds a specified amount of gallons to the bucket. */
    func pour(_ amount: Int, completion: @escaping ((_ successful: Bool)-> Void)) {
        do { try bucket.load(amount) }
        catch {
            print("Bucket Problem: \(error)")
            return completion(false)
        }
        return completion(true)
    }
}


// MARK: WBucketDelegate Methods

extension WBButton: WBucketDelegate {
    
    /// Sets the feedback of changes in water levels.
    func changedWater(_ amount: Int) {
        shouldHighlight = true
        setTitle( "\(amount)", for: UIControlState())
        setTitle( "\(amount)", for: UIControlState.selected)
        setTitle( "\(amount)", for: UIControlState.highlighted)
        isEmpty = amount == 0
    }
}
