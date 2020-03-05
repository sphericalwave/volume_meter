//
//  ProgressUI.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import UIKit

class ProgressUI
{
    @IBOutlet weak var countUpLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    //FIXME: Inject AudioSource
    override func viewDidLoad() {
        super.viewDidLoad()
        countUpLabel.text = formatted(time: 0)
        countDownLabel.text = formatted(time: audioLengthSeconds)
    }
    
//    @objc func updateUI() {
//        currentPosition = currentFrame + seekFrame
//        currentPosition = max(currentPosition, 0)
//        currentPosition = min(currentPosition, audioLengthSamples)
//        
//        progressBar.progress = Float(currentPosition) / Float(audioLengthSamples)
//        let time = Float(currentPosition) / audioSampleRate
//        countUpLabel.text = formatted(time: time)
//        countDownLabel.text = formatted(time: audioLengthSeconds - time)
//        
//        if currentPosition >= audioLengthSamples {
//            player.stop()
//            displayLink?.isPaused = true
//            playPauseButton.isSelected = false
//            disconnectVolumeTap()
//        }
//    }
}
