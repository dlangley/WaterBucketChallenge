//
//  BombVC.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 10/4/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

protocol BombDelegate: class {
    func explode()
}

/// ViewController that represents a bomb used in a container view.
class BombVC: UIViewController {
    
    weak var delegate: BombDelegate?
    var diffuseTrigger = 4 {
        willSet {
            diffuseLabelL.text = String(describing: newValue)
            diffuseLabelR.text = String(describing: newValue)
        }
    }
    var pressure : Int? {
        willSet {
            delegate?.explode()
        }
    }
    var perspective : CATransform3D {
        var rotation = CATransform3DIdentity
        rotation.m34 = 1 / -500
        return CATransform3DRotate(rotation, 45.0 * CGFloat.pi / 180, 0, 1, 0)
    }
    
    @IBOutlet var pressurePlate: UIView!
    @IBOutlet var spring: UIView!
    @IBOutlet var basePlate: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var diffuseLabelL: UILabel!
    @IBOutlet var diffuseLabelR: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        pressurePlate.layer.transform = perspective
//        spring.layer.transform = perspective
//        basePlate.layer.transform = perspective
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
