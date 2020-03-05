//
//  AudioEngine.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import AVFoundation

class AudioEngine: AVAudioEngine
{
    let player: AVAudioPlayerNode
    let rateEffect: AVAudioUnitTimePitch
    
    init(player: AVAudioPlayerNode, rateEffect: AVAudioUnitTimePitch, codec: AVAudioFormat) {
        self.player = player
        self.rateEffect = rateEffect
        super.init()
        self.attach(player)
        self.attach(rateEffect)
        self.connect(player, to: rateEffect, format: codec)
        self.connect(rateEffect, to: self.mainMixerNode, format: codec)
        self.prepare()
        do { try self.start() }
        catch { print(error.localizedDescription) }
    }
    
    func connectVolumeTap() {
        let format = self.mainMixerNode.outputFormat(forBus: 0)
        self.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in
            
            guard let channelData = buffer.floatChannelData /*,
                 //FIXME: let displayLink = self.displayLink*/ else { return }
            
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
        }
    }
    
    func disconnectVolumeTap() {
        self.mainMixerNode.removeTap(onBus: 0)
        //FIXME: volumeMeterHeight.constant = 0
    }
}
