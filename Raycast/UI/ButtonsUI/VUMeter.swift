//
//  VUMeter.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-05.
//  Copyright © 2020 Razeware. All rights reserved.
//

import UIKit

class VUMeter: UIView
{
    let minDecibelPower: Float = -80.0 //dB
    var maxHeight: CGFloat? //FIXME: Be Immutable
    var displayLink: CADisplayLink? //FIXME: Be Immutable
    var percent: Float = 0  //FIXME: Be Immutable
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .red
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink?.isPaused = true
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func percent(from decibelPower: Float) -> Float {
        guard decibelPower.isFinite else { return 0.0 }
        if decibelPower < minDecibelPower { return 0.0 }
        else if decibelPower >= 1.0 { return 1.0 }
        else { return (fabs(minDecibelPower) - fabs(decibelPower)) / fabs(minDecibelPower) }
    }
    
    func bus0(avgPower: Float) {
//        let prcnt = percent(from: avgPower)
//        print(prcnt)
//        let height = maxHeight! * CGFloat(prcnt)
//        let newBounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
//        frame = newBounds
        self.percent = percent(from: avgPower)
        displayLink?.isPaused = false   //FIXME: Redundant

    }
    
    @objc func refresh() {
        let height = maxHeight! * CGFloat(percent)
        let newBounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        frame = newBounds
    }
}
