//
//  BombVw.swift
//  Water Bucket Game
//
//  Created by Dwayne Langley on 10/10/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

protocol BombDelegate: class {
    func explode()
}

@IBDesignable class BombVw: UIView {

    /// Used to instantiate the xib file in the setup.
    var view: UIView!
    var bomb: WBomb! {
        willSet {
            newValue.delegate = self
            diffuseLabelL.text = String(describing: newValue.diffuseTrigger)
            diffuseLabelR.text = String(describing: newValue.diffuseTrigger)
        }
    }
    
    weak var delegate: BombDelegate?
    
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var diffuseLabelL: UILabel!
    @IBOutlet var diffuseLabelR: UILabel!
    
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
        let nib = UINib(nibName: "BombVw", bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}

// MARK: BombLogic implementation
extension BombVw: BombLogic {
    
    func elapsed(to time: Int) {
        timeLabel.text = "\(time)"
        guard time > 0 else {
            delegate?.explode()
            return
        }
    }
    
    func diffuseAttempt(successful: Bool) {
        guard successful else {
            delegate?.explode()
            return
        }
    }
}
