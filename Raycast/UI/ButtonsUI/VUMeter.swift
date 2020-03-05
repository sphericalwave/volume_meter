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
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .red
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func percent(from decibelPower: Float) -> Float {
        guard decibelPower.isFinite else { return 0.0 }
        if decibelPower < minDecibelPower { return 0.0 }
        else if decibelPower >= 1.0 { return 1.0 }
        else { return (fabs(minDecibelPower) - fabs(decibelPower)) / fabs(minDecibelPower) }
    }
}
