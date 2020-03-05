

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
//    let displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
//    let displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
//    displayLink.add(to: .current, forMode: .defaultRunLoopMode)
//    displayLink.isPaused = true
    window?.rootViewController = MainScreen()
    
    return true
  }
}
