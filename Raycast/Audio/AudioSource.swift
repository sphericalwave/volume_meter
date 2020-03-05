//
//  AudioSource.swift
//  Raycast
//
//  Created by Aaron Anthony on 2020-03-04.
//  Copyright © 2020 Razeware. All rights reserved.
//

import AVFoundation

class AudioSource: AVAudioPlayerNode
{
    //var engine = AVAudioEngine()
    //var player = AVAudioPlayerNode()
    //let displayLink: CADisplayLink
    //var audioBuffer: AVAudioPCMBuffer?
    var codec: AVAudioFormat?
    var sampleRate: Float = 0
    var audioLengthSeconds: Float = 0
    var currentFrame: AVAudioFramePosition = 0
    var needsFileScheduled = true
    
    var totalFrames: AVAudioFramePosition {
        guard let lastRenderTime = self.lastRenderTime,
            let playerTime = self.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        return playerTime.sampleTime
    }
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    let minDb: Float = -80.0
    
//    init(displayLink: CADisplayLink) {
//        self.displayLink = displayLink
//        super.init()
//    }
    
    func load(audioFileURL: URL) {
        guard let audioFile = try? AVAudioFile(forReading: audioFileURL) else { fatalError() }
        currentFrame = audioFile.length  //FIXME: QUestionable
        codec = audioFile.processingFormat
        sampleRate = Float(codec?.sampleRate ?? 44100)
        audioLengthSeconds = Float(currentFrame) / sampleRate
        seekFrame = 0
        self.scheduleFile(audioFile, at: nil) { [weak self] in
            self?.needsFileScheduled = true
        }
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
//    func setupAudio() {
//        audioFileURL  = Bundle.main.url(forResource: "Intro", withExtension: "mp4")
//        
//        
////        //Engine Cons
////        engine.attach(player)
////        engine.attach(rateEffect)
////        engine.connect(player, to: rateEffect, format: codec)
////        engine.connect(rateEffect, to: engine.mainMixerNode, format: codec)
////        engine.prepare()
////        do { try engine.start() }
////        catch { print(error.localizedDescription) }
//    }
    
//    func scheduleAudioFile() {
//        //guard let audioFile = audioFile else { return }
//        seekFrame = 0
//        self.scheduleFile(audioFile, at: nil) { [weak self] in
//            self?.needsFileScheduled = true
//        }
//    }
    
    func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        if power < minDb { return 0.0 }
        else if power >= 1.0 { return 1.0 }
        else { return (fabs(minDb) - fabs(power)) / fabs(minDb) }
    }
    
    func seek(to time: Float) {
//        //guard let audioFile = audioFile /*,let displayLink = displayLink*/ else { return }
//
//        seekFrame = currentPosition + AVAudioFramePosition(time * sampleRate)
//        seekFrame = max(seekFrame, 0)
//        seekFrame = min(seekFrame, currentFrame)
//        currentPosition = seekFrame
//
//        self.stop()
//
//        if currentPosition < currentFrame {
//            updateUI()
//            needsFileScheduled = false
//            let frameCount = AVAudioFrameCount(currentFrame - seekFrame)
//            self.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: frameCount, at: nil) { [weak self] in
//                self?.needsFileScheduled = true
//            }
//            if !displayLink.isPaused { self.play() }
//        }
    }
    
    func updateUI() {
        //FIXME: Update UIs maybe
    }
    
}
