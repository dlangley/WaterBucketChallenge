//
//  BucketVw.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 10/6/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

// MARK: Protocol for WBButtonDelegate

/** Protocol used to update WBGameController. */
protocol BucketVwDelegate : class {
    
    /// Does the appropriate action based on the location of the bucket on release.
    func doAction(for sender: BucketVw) -> Void?
    
    /// Tracks the amount of actions performed on a WBButton
    var bucketActions: Int {get set}
}



/// Custom view laid out in nib to clean up the main Storyboard.
@IBDesignable class BucketVw: UIView {
    
    /// Used to instantiate the xib file in the setup.
    var view: UIView!
    
    /** Model Object for this button.
     * Functional - Delegate is set upon setting.
     */
    var bucket : WBucket! {
        willSet {
            newValue.delegate = self
            limitLabel.text = "\(newValue.capacity) gal"
        }
    }
    
    /// Represents the original location for the bucket to return to after movement.
    var spot : CGRect!
    
    /// True when there is no water in the bucket.
    var isEmpty = true 
    
    /// True when the user needs to be updated about a change in the bucket contents.
    var shouldHighlight = false
    
    /// Computed by the starting position of the bucket.
    var isLeftBucket : Bool {
        return spot.midX <= (superview?.bounds.midX)!
    }
    
    /// Anonymous reference to fire delegate methods.
    weak var delegate : BucketVwDelegate?
    
    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var button: UIButton!
    
    
    // MARK:- IBDesignable initializer logic for any instantiation.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: "BucketVw", bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}

// MARK:- LifeCycle Overrides for Touch-Responsive Animation

extension BucketVw {
    
    /** Config the buttons to represent the Water Bucket. */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if bucket == nil {
            bucket = WBucket(with: 0)
        }
        
        spot = frame
    }
    
    /** Override to allow for dragging the button. */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            // Reposition the Button to wherever the finger moves.
            center = touch.location(in: superview)
            
            // Determining animate fill motion when bucket is in the water.
            if center.y >= (superview?.bounds.midY)! /*&& frame.maxY < (superview?.bounds.maxY)! */ {
                let rAmount = center.y/((superview?.bounds.height)!/3)
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
        
        // Only update the move counter if there's an action performed.
        if delegate?.doAction(for: self) != nil {
            delegate?.bucketActions += 1
        }
        
        // Clean up.
        if game.status == .ready {
            snapToOrigin()
        }
    }
}

// MARK:- Non-Touch Animations

extension BucketVw {
    
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
                self.button.isSelected = !self.isEmpty
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
                self.levelLabel?.transform = transform
            })
        }) { (isFinished) in // Clean up the animation
            let trans = CGAffineTransform(rotationAngle: 0)
            self.levelLabel?.transform = trans
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


// MARK:- Bucket Actions

extension BucketVw {
    /** Empties the contents of the bucket. */
    func dump() {
        do {
            try bucket.load(-bucket.content)
        } catch {
            print("Bucket Problem: \(error)")
            return
        }
    }
    
    /** Fills the bucket. */
    func fill() {
        do { try bucket.load(bucket.room) }
        catch {
            print("Bucket Problem: \(error)")
            return
        }
    }
    
    /** Adds a specified amount of gallons to the bucket. */
    func pour(_ amount: Int) {
        do { try bucket.load(amount) }
        catch {
            print("Bucket Problem: \(error)")
        }
    }
}


// MARK:- WBucketDelegate Methods

extension BucketVw: WBucketDelegate {
    
    /// Sets the feedback of changes in water levels.
    func changedWater(_ amount: Int) {
        shouldHighlight = true
        levelLabel.text = "\(amount)"
        isEmpty = amount == 0
    }
}
