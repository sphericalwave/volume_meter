//
//  RateUI.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation

// MARK: - Display related
//
class RateUI
{
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateLabelLeading: NSLayoutConstraint!
    
    let rateSliderValues: [Float] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
    var rateValue: Float = 1.0 {
        didSet {
            rateEffect.rate = rateValue
            updateRateLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRateSlider()
    }
    
    func setupRateSlider() {
        let numSteps = rateSliderValues.count-1
        rateSlider.minimumValue = 0
        rateSlider.maximumValue = Float(numSteps)
        rateSlider.isContinuous = true
        rateSlider.setValue(1.0, animated: false)
        rateValue = 1.0
        updateRateLabel()
    }
    
    func updateRateLabel() {
        rateLabel.text = "\(rateValue)x"
        let trackRect = rateSlider.trackRect(forBounds: rateSlider.bounds)
        let thumbRect = rateSlider.thumbRect(forBounds: rateSlider.bounds , trackRect: trackRect, value: rateSlider.value)
        let x = thumbRect.origin.x + thumbRect.width/2 - rateLabel.frame.width/2
        rateLabelLeading.constant = x
    }
    
    @IBAction func didChangeRateValue(_ sender: UISlider) {
        let index = round(sender.value)
        rateSlider.setValue(Float(index), animated: false)
        rateValue = rateSliderValues[Int(index)]
    }
}
