
import UIKit
import AVFoundation

class MainScreen: UIViewController
{
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var meterView: UIView!
    @IBOutlet weak var volumeMeterHeight: NSLayoutConstraint!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var countUpLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    init() {
        super.init(nibName: "MainScreen", bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("Stop Collaborate and Listen")}
    
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
    let rateSliderValues: [Float] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
    var rateValue: Float = 1.0 {
        didSet {
            rateEffect.rate = rateValue
            updateRateLabel()
        }
    }
    var updater: CADisplayLink?
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        
        return playerTime.sampleTime
    }
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    let pauseImageHeight: Float = 26.0
    let minDb: Float = -80.0
    
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    
    // MARK: - ViewController lifecycle
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRateSlider()
        countUpLabel.text = formatted(time: 0)
        countDownLabel.text = formatted(time: audioLengthSeconds)
        setupAudio()
        
        updater = CADisplayLink(target: self, selector: #selector(updateUI))
        updater?.add(to: .current, forMode: .defaultRunLoopMode)
        updater?.isPaused = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateRateLabel()
    }
}

// MARK: - Actions
//
extension MainScreen {
    @IBAction func didChangeRateValue(_ sender: UISlider) {
        let index = round(sender.value)
        rateSlider.setValue(Float(index), animated: false)
        rateValue = rateSliderValues[Int(index)]
    }
    
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
    
    @objc func updateUI() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        progressBar.progress = Float(currentPosition) / Float(audioLengthSamples)
        let time = Float(currentPosition) / audioSampleRate
        countUpLabel.text = formatted(time: time)
        countDownLabel.text = formatted(time: audioLengthSeconds - time)
        
        if currentPosition >= audioLengthSamples {
            player.stop()
            updater?.isPaused = true
            playPauseButton.isSelected = false
            disconnectVolumeTap()
        }
    }
}

// MARK: - Display related
//
extension MainScreen {
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
}

// MARK: - Audio
//
extension MainScreen {
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
                let updater = self.updater else {
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
                self.volumeMeterHeight.constant = !updater.isPaused ? CGFloat(min((meterLevel * self.pauseImageHeight),
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
            let updater = updater else {
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
            
            if !updater.isPaused {
                player.play()
            }
        }
    }
    
}
