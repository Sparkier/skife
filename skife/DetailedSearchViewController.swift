//
//  DetailedSearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreLocation

class DetailedSearchViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var rider: Rider!
    var lastDistances = [CLLocationAccuracy]()
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Location Manager
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        // Listen to Rider
        locationManager!.startMonitoringForRegion(rider.beaconRegion)
        locationManager!.startRangingBeaconsInRegion(rider.beaconRegion)
        locationManager!.startUpdatingLocation()
    }
    
    // Ranged Beacon by Location Manager
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!,inRegion region: CLBeaconRegion!) {
        var message:String = ""
        
        if beacons.count > 0 {
            self.distanceLabel.text = "Distance about \(round(beacons[0].accuracy*100.0)/100.0) meters."
            self.lastDistances.append(beacons[0].accuracy)
            if self.lastDistances.count > 2 {
                self.lastDistances.removeAtIndex(0)
            }
            if lastDistances.count == 2 {
                self.checkDirection()
            }
        }
    }
    
    // Checks if User moves in correct Direction
    func checkDirection() {
        if lastDistances[0] > lastDistances[1] {
            self.view.backgroundColor = UIColor.greenColor()
        } else {
            self.view.backgroundColor = UIColor.redColor()
        }
    }
}
