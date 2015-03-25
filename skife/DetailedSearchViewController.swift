//
//  DetailedSearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailedSearchViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var rider: Rider!
    var closeLabel: UILabel!
    var goingBack: Bool = false
    let directionEngine = DirectionEngine()
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Location Manager for Beacons
        locationManager = CLLocationManager()
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        // Listen to Rider
        locationManager!.startMonitoringForRegion(rider.beaconRegion)
        locationManager!.startRangingBeaconsInRegion(rider.beaconRegion)
        locationManager!.startUpdatingLocation()
        
        // Set up Close Label
        closeLabel = UILabel(frame: self.view.frame)
        closeLabel.font = closeLabel.font.fontWithSize(50.0)
        closeLabel.textAlignment = NSTextAlignment.Center
    }
    
    // Ranged Beacon by Location Manager
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!,inRegion region: CLBeaconRegion!) {
        var message:String = ""
        
        if beacons.count > 0 {
            self.distanceLabel.text = "Distance about \(round(beacons[0].accuracy*100.0)/100.0) meters."
            self.closeLabel.text = "\(round(beacons[0].accuracy*100.0)/100.0)"
            self.directionEngine.previousDistances.append(beacons[0].accuracy)
            self.directionEngine.inRange = true
            if directionEngine.closestPoint > beacons[0].accuracy {
                self.directionEngine.closestPoint = beacons[0].accuracy
            }
            self.checkDistance()
        } else {
            self.directionEngine.inRange = false
            self.distanceLabel.text = "Not in Range."
            if self.directionEngine.previousDistances.count > 0 {
                
            }
        }
        
        // Get Direction from DirectionEngine
        let dir = directionEngine.getDirection()
        if dir == Direction.Any {
            directionLabel.text = "Please go where you think the Sender might be burrowed."
        } else if dir == Direction.Back && directionEngine.inRange == false {
            directionLabel.text = "You lost Connection to the Sender. Please move back to where you had a connection."
        } else if dir == Direction.Back {
            self.directionLabel.text = "Turn around and go back to where your distance was about \(round(directionEngine.closestPoint*100.0)/100.0). Then turn left or right."
        }
    }
    
    // Checks if User is really Close to the Sender
    func checkDistance() {
        let lastDistance = self.directionEngine.previousDistances.last
        if lastDistance <= 3.0 {
            self.distanceLabel.hidden = true
            self.view.addSubview(closeLabel)
        } else if lastDistance > 3.0 {
            self.closeLabel.removeFromSuperview()
            self.distanceLabel.hidden = false
        }
    }
}
