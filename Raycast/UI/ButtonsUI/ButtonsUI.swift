//
//  ButtonsUI.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import UIKit

class ButtonsUI
{
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    let audioSource: AudioSource
    
    init(audioSource: AudioSource) {
        self.audioSource = audioSource
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected
        //if currentPosition >= currentFrame { updateUI() }
        
        if audioSource.isPlaying {
//            disconnectVolumeTap()
//            displayLink?.isPaused = true
            audioSource.pause()
            
        } else {
//            displayLink?.isPaused = false
//            connectVolumeTap()
//            if needsFileScheduled {
//                needsFileScheduled = false
//                scheduleAudioFile()
//            }
            audioSource.play()
        }
    }
    
    @IBAction func plus10Tapped(_ sender: UIButton) {
        //guard let _ = player.engine else { return }
        audioSource.seek(to: 10.0)
    }
    
    @IBAction func minus10Tapped(_ sender: UIButton) {
//        guard let _ = player.engine else { return }
//        needsFileScheduled = false
        audioSource.seek(to: -10.0)
    }
}


