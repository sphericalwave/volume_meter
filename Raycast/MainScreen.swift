
import UIKit
//import AVFoundation

class MainScreen: UIViewController
{
    var updater: CADisplayLink?  //timer

    init() {
        super.init(nibName: "MainScreen", bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("Stop Collaborate and Listen")}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updater = CADisplayLink(target: self, selector: #selector(updateUI))
        updater?.add(to: .current, forMode: .defaultRunLoopMode)
        updater?.isPaused = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateRateLabel()
    }
}





