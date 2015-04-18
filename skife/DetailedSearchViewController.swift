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
    
    @IBOutlet weak var directionImageView: UIImageView!
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
            self.distanceLabel.text = "~ \(round(beacons[0].accuracy*100.0)/100.0) m"
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
        self.checkDirection()
    }
    
    // Locating the User and Updating the Map
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        previousLocations.append(locations[0] as! CLLocation)
        self.map.setCenterCoordinate(map.userLocation.coordinate, animated: true)

        if (previousLocations.count > 1){
            var a: [CLLocationCoordinate2D] = []
            a.append(previousLocations[previousLocations.count-2].coordinate)
            a.append(previousLocations[previousLocations.count-1].coordinate)
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            self.map.addOverlay(polyline)
        }
    }
    
    // Drawing Line where User walks
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var circle = MKPolylineRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return nil
        }
    }
    
    // Checks if User is really Close to the Sender
    func checkDistance() {
        let lastDistance = self.directionEngine.previousDistances.last
        if lastDistance <= 3.0 {
            self.distanceLabel.hidden = true
            self.directionImageView.hidden = true
            self.view.addSubview(closeLabel)
        } else if lastDistance > 3.0 {
            self.closeLabel.removeFromSuperview()
            self.distanceLabel.hidden = false
            self.directionImageView.hidden = false
        }
    }
}
