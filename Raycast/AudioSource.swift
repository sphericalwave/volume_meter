//
//  AudioSource.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import AVFoundation

class AudioSource
{
    // MARK: AVAudio properties
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var rateEffect = AVAudioUnitTimePitch()
    
    var audioFile: AVAudioFile? {
        didSet {
            if let audioFile = audioFile {
                audioLengthSamples = audioFile.length
                audioFormat = audioFile.processingFormat
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
            }
        }
    }
    var audioFileURL: URL? {
        didSet {
            if let audioFileURL = audioFileURL {
                audioFile = try? AVAudioFile(forReading: audioFileURL)
            }
        }
    }
    var audioBuffer: AVAudioPCMBuffer?
    
    // MARK: other properties
    var audioFormat: AVAudioFormat?
    var audioSampleRate: Float = 0
    var audioLengthSeconds: Float = 0
    var audioLengthSamples: AVAudioFramePosition = 0
    var needsFileScheduled = true
    
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        
        return playerTime.sampleTime
    }
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    let minDb: Float = -80.0
    
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    
    //FIXME: - Request Current Time
    func formatted(time: Float) -> String {
        var secs = Int(ceil(time))
        var hours = 0
        var mins = 0
        
        if secs > TimeConstant.secsPerHour {
            hours = secs / TimeConstant.secsPerHour
            secs -= hours * TimeConstant.secsPerHour
        }
        
        if secs > TimeConstant.secsPerMin {
            mins = secs / TimeConstant.secsPerMin
            secs -= mins * TimeConstant.secsPerMin
        }
        
        var formattedString = ""
        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }
        formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", secs))"
        return formattedString
    }
    
    

// MARK: - Audio
//
    func setupAudio() {
        audioFileURL  = Bundle.main.url(forResource: "Intro", withExtension: "mp4")
        
        engine.attach(player)
        engine.attach(rateEffect)
        engine.connect(player, to: rateEffect, format: audioFormat)
        engine.connect(rateEffect, to: engine.mainMixerNode, format: audioFormat)
        
        engine.prepare()
        
        do {
            try engine.start()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func scheduleAudioFile() {
        guard let audioFile = audioFile else { return }
        
        seekFrame = 0
        player.scheduleFile(audioFile, at: nil) { [weak self] in
            self?.needsFileScheduled = true
        }
    }
    
    func connectVolumeTap() {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in
            
            guard let channelData = buffer.floatChannelData,
                let displayLink = self.displayLink else {
                    return
            }
            
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0,
                                               to: Int(buffer.frameLength),
                                               by: buffer.stride).map{ channelDataValue[$0] }
            let red = channelDataValueArray.map{ $0 * $0 }.reduce(0, +)
            let rms = sqrt(red / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)
            let meterLevel = self.scaledPower(power: avgPower)
            
            DispatchQueue.main.async {
                self.volumeMeterHeight.constant = !displayLink.isPaused ? CGFloat(min((meterLevel * self.pauseImageHeight),
                                                                                  self.pauseImageHeight)) : 0.0
            }
        }
    }
    
    func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (fabs(minDb) - fabs(power)) / fabs(minDb)
        }
    }
    
    func disconnectVolumeTap() {
        engine.mainMixerNode.removeTap(onBus: 0)
        volumeMeterHeight.constant = 0
    }
    
    func seek(to time: Float) {
        guard let audioFile = audioFile,
            let displayLink = displayLink else {
                return
        }
        
        seekFrame = currentPosition + AVAudioFramePosition(time * audioSampleRate)
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        player.stop()
        
        if currentPosition < audioLengthSamples {
            updateUI()
            needsFileScheduled = false
            
            player.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: AVAudioFrameCount(audioLengthSamples - seekFrame), at: nil) { [weak self] in
                self?.needsFileScheduled = true
            }
            
            if !displayLink.isPaused {
                player.play()
            }
        }
    }
    
}
