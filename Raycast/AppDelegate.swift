

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    //window?.rootViewController = MainScreen()
    
    let vuMeter = VUMeter()
    
    guard let url = Bundle.main.url(forResource: "Intro", withExtension: "mp4") else { fatalError() }
    do {
      let audioFile = try AVAudioFile(forReading: url)
      let codec = audioFile.processingFormat
      let audioSource = AudioSource(audioFile: audioFile)
      let audioRate = AudioRate()
      let audioEngine = AudioEngine(player: audioSource, rateEffect: audioRate, codec: codec)
      window?.rootViewController = TestScreen(volumeMeter: vuMeter, audioSource: audioSource, audioEngine: audioEngine) //MainScreen()
    }
    catch { print(error) }

    return true
  }
}
