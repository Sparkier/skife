//
//  InclinationViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.05.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import CoreMotion

class InclinationViewController: UIViewController {
    var motionManager = CMMotionManager()
    var timer: NSTimer!
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    @IBOutlet weak var lbPitch: UILabel!
    
    override func viewDidLoad() {
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: { motion, error in
            // compute the device Pitch
            let myPitch = self.radiansToDegrees(self.motionManager.deviceMotion.attitude.pitch)
            var intPitch = myPitch > 0 ? Int(myPitch) : 0
            dispatch_async(dispatch_get_main_queue()) {
                self.lbPitch.text = "\(intPitch)°"
            }
        });
    }
    
    func radiansToDegrees(radians: Double) -> Double {
        return (radians * (180.0 / M_PI))
    }
}