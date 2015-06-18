//
//  InclinationViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.05.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import CoreMotion
import QuartzCore
import CoreLocation

class InclinationViewController: RevealBaseViewController, CLLocationManagerDelegate {
    var motionManager = CMMotionManager()
    var timer: NSTimer!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var imgCompass: UIImageView!
    @IBOutlet weak var lbPitch: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgImg.removeFromSuperview()
        
        // Updating Inclination Label
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: { motion, error in
            // compute the device Pitch
            let myPitch = self.radiansToDegrees(self.motionManager.deviceMotion.attitude.pitch)
            var intPitch = myPitch > 0 ? Int(myPitch) : 0
            dispatch_async(dispatch_get_main_queue()) {
                self.lbPitch.text = "\(intPitch)°"
            }
        });
        
        // LocationManager for Compass  
        locationManager.headingFilter = 1
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
    }
    
    // Transforms Radians into Degrees
    func radiansToDegrees(radians: Double) -> Double {
        return (radians * (180.0 / M_PI))
    }
    
    // Update Compass
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        // Convert Degree to Radian and move the needle
        var oldRad =  Float(-manager.heading.trueHeading * M_PI / 180.0)
        var newRad =  Float(-newHeading.trueHeading * M_PI / 180.0)
        let theAnimation = CABasicAnimation(keyPath: "transform.rotation")
        theAnimation.fromValue = NSNumber(float: oldRad)
        theAnimation.toValue = NSNumber(float: newRad)
        theAnimation.duration = 0.5
        imgCompass.layer.addAnimation(theAnimation, forKey: "animateMyRotation")
        imgCompass.transform = CGAffineTransformMakeRotation(CGFloat(newRad))
    }
}