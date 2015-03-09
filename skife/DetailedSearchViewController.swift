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
    var previousLocations: [CLLocation] = []
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
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
        
        // Set up Map
        map.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
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
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        previousLocations.append(locations[0] as CLLocation)

        if (previousLocations.count > 1){
            var sourceIndex = previousLocations.count - 1
            var destinationIndex = previousLocations.count - 2
            
            let c1 = previousLocations[sourceIndex].coordinate
            let c2 = previousLocations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            self.map.addOverlay(polyline)
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
