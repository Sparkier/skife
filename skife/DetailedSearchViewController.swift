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
    var lastDistances = [CLLocationAccuracy]()
    var closeLabel: UILabel!
    var goingBack: Bool = false
    var closestPoint: CLLocationAccuracy?
    
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
            self.lastDistances.append(beacons[0].accuracy)
            if let cp = self.closestPoint {
                if cp > beacons[0].accuracy{
                    self.closestPoint = beacons[0].accuracy
                }
            } else {
                self.closestPoint = beacons[0].accuracy
            }
            if self.lastDistances.count > 2 {
                self.lastDistances.removeAtIndex(0)
            }
            self.checkDistance()
        } else {
            self.distanceLabel.text = "Not in Range."
            if lastDistances.count > 0 {
                directionLabel.text = "You lost Connection to the Sender. Please move back to where you had a connection."
            } else {
                directionLabel.text = "Please go where you think the Sender might be burrowed."
            }
        }
    }
    
    // Checks if User is really Close to the Sender
    func checkDistance() {
        let lastDistance = lastDistances.last
        if lastDistance <= 3.0 {
            self.distanceLabel.removeFromSuperview()
            self.view.addSubview(closeLabel)
        } else if lastDistance > 3.0 {
            self.closeLabel.removeFromSuperview()
            self.view.addSubview(distanceLabel)
            if closestPoint!+5 < lastDistance {
                self.directionLabel.text = "Turn around and go back to where your distance is about \(round(closestPoint!*100.0)/100.0). Then turn left or right."
            } else if !goingBack {
                self.directionLabel.text = "Keep on walking this Direction."
            }
        }
    }
}
