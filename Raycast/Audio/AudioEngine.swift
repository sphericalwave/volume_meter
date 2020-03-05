//
//  AudioEngine.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import AVFoundation

protocol AudioEngineDelegate: AnyObject {
    func bus0(avgPower: Float)
}

class AudioEngine: AVAudioEngine
{
    let player: AudioSource
    let rateEffect: AudioRate
    weak var delegate: AudioEngineDelegate?
    let notifications = NotificationCenter.default  //FIXME: Hidden Dependency
    let vuMeter: VUMeter

    
    init(player: AudioSource, rateEffect: AudioRate, codec: AVAudioFormat, vuMeter: VUMeter) {
        self.player = player
        self.rateEffect = rateEffect
        self.vuMeter = vuMeter
        super.init()
        attach(player)
        //attach(rateEffect)
        //connect(player, to: rateEffect, format: codec)
        //connect(rateEffect, to: mainMixerNode, format: codec) //FIXME: Rate Effect
        connect(player, to: mainMixerNode, format: codec)
        prepare()
        do { try start() }
        catch { print(error.localizedDescription) }
        //notifications.addObserver(self, selector: #selector(connectVolumeTap), name: .didPlay, object: nil)
        connectVolumeTap()
    }
    
    func connectVolumeTap() {
        let format = mainMixerNode.outputFormat(forBus: 0)
        mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in
            guard let channelData = buffer.floatChannelData else { return }
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{ channelDataValue[$0] }
            let red = channelDataValueArray.map{ $0 * $0 }.reduce(0, +)
            let rms = sqrt(red / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)
            //FIXME: let meterLevel = self.scaledPower(power: avgPower)
            //            DispatchQueue.main.async {
            //                self.volumeMeterHeight.constant = !displayLink.isPaused ? CGFloat(min((meterLevel * self.pauseImageHeight),
            //                                                                                  self.pauseImageHeight)) : 0.0
            //            }
            //FIXME: Add to Meter Height
            
            //DispatchQueue.main.async { self.delegate?.bus0(avgPower: avgPower) }
            
            DispatchQueue.main.async { self.vuMeter.bus0(avgPower: avgPower) }
        }
    }
    
    func disconnectVolumeTap() {
        mainMixerNode.removeTap(onBus: 0)
        //FIXME: volumeMeterHeight.constant = 0
    }
}
