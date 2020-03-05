
import UIKit
//import AVFoundation

class MainScreen: UIViewController
{
    //let displayLink: CADisplayLink  //timer

    init() {
        //self.displayLink = displayLink
//        self.displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
//        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
//        displayLink.isPaused = true
        super.init(nibName: "MainScreen", bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("Stop Collaborate and Listen")}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME: Inject DisplayLink
//        //displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
//        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
//        displayLink.isPaused = true
    }
    
    @objc func updateUI() { }
}





