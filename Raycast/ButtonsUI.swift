//
//  ButtonsUI.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation

class ButtonsUI
{
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    
    @IBAction func playTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if currentPosition >= audioLengthSamples {
            updateUI()
        }
        
        if player.isPlaying {
            disconnectVolumeTap()
            updater?.isPaused = true
            player.pause()
        } else {
            updater?.isPaused = false
            connectVolumeTap()
            if needsFileScheduled {
                needsFileScheduled = false
                scheduleAudioFile()
            }
            player.play()
        }
    }
    
    @IBAction func plus10Tapped(_ sender: UIButton) {
        guard let _ = player.engine else { return }
        seek(to: 10.0)
    }
    
    @IBAction func minus10Tapped(_ sender: UIButton) {
        guard let _ = player.engine else { return }
        needsFileScheduled = false
        seek(to: -10.0)
    }
}


