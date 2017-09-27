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
    
    /** Represents the part of the screen that user interacts with to solve the puzzle. */
    @IBOutlet var gameSpace: UIView!
    
    /** Represents the pending doom if user does not solve the puzzle in time. */
    @IBOutlet var bombImage: UIImageView!
    
    /** Displays the remaining time. 
    * Functional - Updats game state to failure when time runs out.
    */
    @IBOutlet var timeLabel: UILabel!
    
    
    // MARK: - Properties
    
    /** Timer to drive the countdown for the Bucket Puzzle. */
    private var timer : Timer!
    
    /** Remaining time in the game.
     * Functional - Updates the timeLabel.
     * Functional - Triggers failure event when time runs out.
     */
    private var remainingTime : Int! {
        willSet {
            if newValue == 0 {
                game.status = .failed
            }
            self.timeLabel.text = "\(newValue!)"
        }
    }
    
    /** Represents the amount of moves made so far.
    * Functional - Updates status label and puzzle solved condition.
    */
    var count = 0 {
        willSet {
            status.text = "\(newValue) Moves"
            
            // Ends the game if the goal is reached.
            if (one.bucket.content == game.target && two.isEmpty) || (two.bucket.content == game.target && one.isEmpty) {
                game.status = .solved
            }
        }
    }
    
    
    // MARK: UIViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        game.delegate = self
        one.delegate = self
        two.delegate = self
        setBuckets()
        
    }

    
    // MARK: Instance Methods
    
    /** Implements the countdown. */
    @objc func countDown() {
        remainingTime = remainingTime - 1
    }
    
    /** Configures the WBButtons and Bucket Values according to the game settings. */
    func setBuckets() {
        one.bucket = WBucket(with: game.bucket1)
        bucketLabel1.text = "\(game.bucket1!) Gallons"
        
        two.bucket = WBucket(with: game.bucket2)
        bucketLabel2.text = "\(game.bucket2!) Gallons"
        
        targetLabel.text = "\(game.target!)"
        remainingTime = game.time
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WBGameController.countDown), userInfo: nil, repeats: true)
    }
    
    /** Provides Feedback - Game is Ready */
    func puzzleReady() {
        self.setBuckets()
        gameSpace.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.white
    }
    
    /** Provides Feedback for Success or Failure */
    func puzzleEnded(_ solved: Bool) {
        timer.invalidate()
        gameSpace.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4) { () -> Void in
            self.view.backgroundColor = solved ? UIColor.green : UIColor.red
        }
    }
    
    
    // MARK: IBActions
    // TODO: Move Reset functions to a menu.
    
    /** Empties the buckets, resets the count, and allows for changing the buckets.  Quick and sloppy version. */
    @IBAction func resetAction(_ sender: UIButton) {
        one.dump()
        two.dump()
        count = 0
        if timer.isValid {
            timer.invalidate()
        }
        
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
    }
}

    
// MARK: WBButtonDelegate Implementation
    
extension WBGameController: WBButtonDelegate {
    
    /** Called to update the recipient bucket in a transfer action. */
    func completeXfer(_ sender: WBButton, amount: Int, completion: @escaping ((Bool) -> Void)) {
        let recipient = sender == two ? one : two
        recipient?.pour(amount) { (successful) in
            recipient?.isSelected = !(recipient?.isEmpty)!
            return completion(successful)
        }
        return completion(true)
    }
    
    
    /** Called in response to a successful bucket move. */
    func moveMade() {
        count += 1
    }
    
    /** Called to evaluate the intent and amount of a transfer action. */
    func crossBuckets(_ sender: WBButton) -> (Bool, Int) {
        let recipient = sender == two ? one : two
        let xferSpace = abs((recipient?.bucket.capacity)! - (recipient?.bucket.content)!)
        let xferAmount = sender.bucket.content <= xferSpace ? sender.bucket.content : xferSpace
        return (one.frame.intersects(two.frame), xferAmount)
    }
}

    
// MARK: GameDelegate Implementation
    
extension WBGameController: GameDelegate {
    
    /** Performs the proper action based on the game state */
    func gameStatusChanged(_ iValue: Int) {
        
        if let check = Game.state(rawValue: iValue) {
            switch check {
            case .ready: puzzleReady()
            case .solved: fallthrough //puzzleSolved()
            case .failed: fallthrough //puzzleFailed()
            default: puzzleEnded(check == .solved)
            }
        }
    }
}

