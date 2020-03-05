
import UIKit
//import AVFoundation

class MainScreen: UIViewController
{
    var displayLink: CADisplayLink?  //timer

    init(displayLink: CADisplayLink) {
        super.init(nibName: "MainScreen", bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("Stop Collaborate and Listen")}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink?.isPaused = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateRateLabel()
    }
}





