//
//  ViewController.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/5/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import UIKit

// MARK: - WBGameController

/** Custom View controller to interface with the user during the game. */
class WBGameController: UIViewController {

    // MARK: - IBOutlets
    
    /** Represents the bucket on the left.*/
    @IBOutlet var one: WBButton!
    
    /** Represents the bucket on the right.*/
    @IBOutlet var two: WBButton!
    
    /** Represents the capactity label for the bucket on the left.*/
    @IBOutlet var bucketLabel1: UILabel!
    
    /** Represents the capactity label for the bucket on the right.*/
    @IBOutlet var bucketLabel2: UILabel!
    
    /** Represents the target amount of gallons we want to get.*/
    @IBOutlet var targetLabel: UILabel!
    
    /** Updates the user on the amount of moves. */
    @IBOutlet var status: UILabel!
    
    
    //MARK: - Properties
    
    /** Storing the original posotions of the Buckets for return animation. */
    var originalSpotOne, originalSpotTwo : CGRect?
    
    /** Represents the amounct of moves made so far.
    * Functional - Updates status label. 
    */
    var count = 0 {
        willSet {
            status.text = "\(newValue) Moves"
        }
    }
    
    
    // MARK: - UIViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setBuckets()
    }

    
    // MARK: - Setup Method
    
    /** Configures the WBButtons and Bucket Values according to the game settings. */
    func setBuckets() {
        originalSpotOne = one.frame
        one.bucket = WBucket(withCapacity: game.bucket1)
        bucketLabel1.text = "\(game.bucket1) Gallons"
        
        originalSpotTwo = two.frame
        two.bucket = WBucket(withCapacity: game.bucket2)
        bucketLabel2.text = "\(game.bucket2) Gallons"
        
        targetLabel.text = "\(game.target)"
    }
    
    
    // MARK: - IBActions
    
    // TODO: - 2nd Button return location is not consistent.
    /** Determines the correct action, executes it, and returns bucket to original position. */
    @IBAction func returnAction(sender: WBButton) {
        
        if CGRectIntersectsRect(one.frame, two.frame) {
            transfer(sender)
        } else if sender.frame.midY > originalSpotOne!.maxY {
            fill(sender)
        } else {
            dump(sender)
        }
        
        UIView.animateWithDuration(0.25) { () -> Void in
            sender.frame.origin = ((sender == self.one) ? self.originalSpotOne!.origin : self.originalSpotTwo!.origin)
        }
    }
    
    // TODO: Move Reset functions to a menu.
    /** Empties the buckets, resets the count, and allows for changing the buckets.  Quick and sloppy version. */
    @IBAction func resetAction(sender: UIButton) {
        dump(one)
        dump(two)
        count = 0
        
        let alert = UIAlertController(title: "Reset", message: "Change Buckets?", preferredStyle: UIAlertControllerStyle.Alert)
        let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            game.bucket1 = Int((alert.textFields?.first?.text)!)
            game.bucket2 =  Int((alert.textFields?[1].text)!)
            game.target = Int((alert.textFields?.last?.text)!)
            self.setBuckets()
        }
        let no = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addTextFieldWithConfigurationHandler { (field: UITextField) -> Void in
            field.keyboardType = UIKeyboardType.DecimalPad
            field.placeholder = "1st Bucket"
        }
        alert.addTextFieldWithConfigurationHandler { (field: UITextField) -> Void in
            field.keyboardType = UIKeyboardType.DecimalPad
            field.placeholder = "2nd Bucket"
        }
        alert.addTextFieldWithConfigurationHandler { (field: UITextField) -> Void in
            field.keyboardType = UIKeyboardType.DecimalPad
            field.placeholder = "Target"
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    
    // MARK: - Bucket Game Actions
    
    /** Attempts to fill a bucket to capacity.
    * Updates the count if successful.
    */
    func fill(sender: WBButton!) {
        if sender.bucket.fill() {
            count += 1
        }
    }
    
    /** Attempts to empty a bucket.
    * Updates the count if successful.
    */
    func dump(sender: WBButton!) {
        if sender.bucket.empty() {
            count += 1
        }
    }
    
    /** Attempts to transfer from one bucket to another.
    * Updates the count if successful.
    */
    func transfer(sender: WBButton!) {
        let recipient = sender == two ? one : two
        let xferSpace = abs(recipient.bucket.capacity - recipient.bucket.content)
        let xferAmount = sender.bucket.content <= xferSpace ? sender.bucket.content : xferSpace
        if recipient.bucket.take(xferAmount) && sender.bucket.take(-xferAmount) {
            count += 1
        }
    }
}

