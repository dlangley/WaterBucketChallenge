//
//  ViewController.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 2/5/16.
//  Copyright © 2016 Dwayne Langley. All rights reserved.
//

import UIKit

/** Custom View controller to interface with the user during the game. */
class WBGameController: UIViewController {

    // MARK:- IBOutlets
    
    /// Represents the bucket on the left.
    @IBOutlet var bucketView1: BucketVw!
    
    /// Represents the bucket on the right.
    @IBOutlet var bucketView2: BucketVw!
    
    /// Represents the bomb.
    @IBOutlet var bombView: BombVw!
    
    /// Updates the user on the amount of moves.
    @IBOutlet var status: UILabel?
    
    // MARK:- Properties
    
    /// Conforms to the BucketVwDelegate Protocol.
    /// Functional - Updates the status label.
    var bucketActions: Int = 0 {
        willSet {
            status?.text = newValue > 0 ? "\(newValue) Moves" : "Begin"
        }
    }
    
    @IBInspectable var bucketsEnabled: Bool {
        get {
            return bucketView1.isUserInteractionEnabled && bucketView2.isUserInteractionEnabled
        }
        set {
            bucketView1.isUserInteractionEnabled = newValue
            bucketView2.isUserInteractionEnabled = newValue
        }
    }
    
    // MARK:- UIViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        game.delegate = self
        bucketView1.delegate = self
        bucketView2.delegate = self
        bombView.delegate = self
        setBuckets()
    }

    
    // MARK:- Instance Methods
    
    /** Configures the WBButtons and Bucket Values according to the game settings. */
    func setBuckets() {
        bucketView1.bucket = WBucket(with: game.bucket1)
        bucketView2.bucket = WBucket(with: game.bucket2)
        bombView.bomb = WBomb(with: game.target, and: game.time)
    }
    
    /** Provides Feedback - Game is Ready */
    func puzzleReady() {
        self.setBuckets()
        view.backgroundColor = UIColor.white
    }
    
    /** Provides Feedback for Success or Failure */
    func puzzleEnded(_ solved: Bool) {
        bucketsEnabled = false
        UIView.animate(withDuration: 0.4) { () -> Void in
            self.view.backgroundColor = solved ? UIColor.green : UIColor.red
        }
    }
    
    
    // MARK:- IBActions
    // FIXME: Move Reset functions to a menu.
    
    fileprivate func resetGame() {
        bucketsEnabled = false
        
        bucketView1.dump()
        bucketView1.snapToOrigin()
        bucketView2.dump()
        bucketView2.snapToOrigin()
        bucketActions = 0
        
        let alert = UIAlertController(title: "Reset", message: "Change Buckets?", preferredStyle: UIAlertControllerStyle.alert)
        let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
            
            let b1 = Int((alert.textFields?.first?.text)!)
            let b2 =  Int((alert.textFields?[1].text)!)
            let t = Int((alert.textFields?.last?.text)!)
            
            game.configure(b1, buc2: b2, targ: t, completion: {
                self.setBuckets()
            })
        }
        let no = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { ( action: UIAlertAction) -> Void in
            game.configure(completion: {
                self.setBuckets()
            })
        }
        alert.addTextField { (field: UITextField) -> Void in
            field.keyboardType = UIKeyboardType.decimalPad
            field.placeholder = "1st Bucket"
        }
        alert.addTextField { (field: UITextField) -> Void in
            field.keyboardType = UIKeyboardType.decimalPad
            field.placeholder = "2nd Bucket"
        }
        alert.addTextField { (field: UITextField) -> Void in
            field.keyboardType = UIKeyboardType.decimalPad
            field.placeholder = "Target"
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        present(alert, animated: false, completion: nil)
        view.setNeedsLayout()
    }
    
    /** Empties the buckets, resets the count, and allows for changing the buckets.  Quick and sloppy version. */
    @IBAction func resetAction(_ sender: UIButton) {
        if sender.isSelected { // Reset the game
            resetGame()
        } else { // Start the game
            bucketsEnabled = true
            bombView.bomb.setItOff()
        }
        
        // Set the bomb timer
        sender.isSelected = !sender.isSelected
    }
}

    
// MARK:- BucketVwDelegate Implementation
    
extension WBGameController: BucketVwDelegate {
    func doAction(for sender: BucketVw) -> Void? {
        
        let recipient = sender == bucketView2 ? bucketView1 : bucketView2
        
        switch sender.frame {
            // End Condition
        case let frame where frame.intersects(bombView.frame) && sender.bucket.content > 0:
            game.status = sender.bucket.content == bombView.bomb.diffuseTrigger ? .solved : .failed
            return nil
            // Transfer Condition
        case let frame where frame.intersects(recipient!.frame) && sender.bucket.content > 0 && recipient!.bucket.room > 0:
            let xferAmount = min(sender.bucket.content, recipient!.bucket.room)
            recipient?.pour(xferAmount)
            recipient?.snapToOrigin()
            return sender.pour(-xferAmount)
            // Dump Condition
        case let frame where frame.minY < 0 && !sender.isEmpty:
            return sender.dump()
            // Fill Condition
        case let frame where frame.midY > (sender.superview?.frame.midY)! && sender.bucket.room > 0:
            return sender.fill()
        default:
            return nil
        }
    }
}

// MARK:- BombDelegate Implementation
extension WBGameController: BombDelegate {
    func explode() {
        game.status = .failed
    }
}
    
// MARK:- GameDelegate Implementation
extension WBGameController: GameDelegate {
    
    /** Performs the proper action based on the game state */
    func gameStatusChanged(_ iValue: Int) {
        
        if let check = Game.state(rawValue: iValue) {
            switch check {
            case .ready: puzzleReady()
            case .solved: fallthrough
            case .failed: fallthrough
            default: puzzleEnded(check == .solved)
            }
        }
    }
}
