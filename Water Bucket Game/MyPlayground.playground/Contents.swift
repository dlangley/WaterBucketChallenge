//: Playground - noun: a place where people can play

import UIKit

extension Double {
    func rnd(precision: Int) -> Double {
        var multiplier : Double = 0
        for x in 0...precision {
            multiplier = pow(10, Double(precision))
        }
        multiplier
        var result = round(self * multiplier)/multiplier
        return result
    }
}

var dec : Double = 0.01
dec -= 0.01
var moddedDec = dec % 1.0
var lDec = round(moddedDec*1000)/1000
var fDec = moddedDec.rnd(3)
var mDec = dec % 0.99
var isWhole = fDec % 1.0 == 1.0