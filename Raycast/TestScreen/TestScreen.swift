//
//  TestScreen.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-05.
//  Copyright © 2020 Razeware. All rights reserved.
//

import UIKit

class TestScreen: UIViewController
{
    let volumeMeter: VUMeter
    let audioSource: AudioSource
    let audioEngine: AudioEngine
    @IBOutlet weak var volumeMeterContainer: UIView!
    
    init(volumeMeter: VUMeter, audioSource: AudioSource, audioEngine: AudioEngine) {
        self.volumeMeter = volumeMeter
        self.audioSource = audioSource
        self.audioEngine = audioEngine
        super.init(nibName: "TestScreen", bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        volumeMeterContainer.addSubview(volumeMeter)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        volumeMeter.frame = volumeMeterContainer.bounds
        audioSource.play()
    }
}
