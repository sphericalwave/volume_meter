//
//  RateUI.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import UIKit

// MARK: - Display related
//
class RateUI: UIViewController
{
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateLabelLeading: NSLayoutConstraint!
    let rateSliderValues: [Float] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
//    var rateValue: Float = 1.0 {
//        didSet {
//            rateEffect.rate = rateValue
//            updateRateLabel()
//        }
//    }
    
    let audioSource: AudioSource
    let audioRate: AudioRate
    
    init(audioSource: AudioSource, audioRate: AudioRate) {
        self.audioSource = audioSource
        self.audioRate = audioRate
        super.init(nibName: "RateUI", bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRateSlider()
        updateRateLabel()
    }
    
    func setupRateSlider() {
        let numSteps = rateSliderValues.count-1
        rateSlider.minimumValue = 0
        rateSlider.maximumValue = Float(numSteps)
        rateSlider.isContinuous = true
        rateSlider.setValue(1.0, animated: false)
        //rateValue = 1.0
        updateRateLabel()
    }
    
    func updateRateLabel() {
//        rateLabel.text = "\(rateValue)x"
        let trackRect = rateSlider.trackRect(forBounds: rateSlider.bounds)
        let thumbRect = rateSlider.thumbRect(forBounds: rateSlider.bounds , trackRect: trackRect, value: rateSlider.value)
        let x = thumbRect.origin.x + thumbRect.width/2 - rateLabel.frame.width/2
        rateLabelLeading.constant = x
    }
    
    @IBAction func didChangeRateValue(_ sender: UISlider) {
        let index = round(sender.value)
        rateSlider.setValue(Float(index), animated: false)
        let rateValue = rateSliderValues[Int(index)]
        rateLabel.text = "\(rateValue)x"

        
//        rateEffect.rate = rateValue
//        updateRateLabel()
    }
}
