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

class DetailedSearchViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager?
    var rider: Rider!
    var lastDistances = [CLLocationAccuracy]()
    var previousLocations: [CLLocation] = []
    var mapOnScreen: Bool = true
    var closeLabel: UILabel!
    
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
        self.map.camera.altitude = 30
        
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
            if self.lastDistances.count > 2 {
                self.lastDistances.removeAtIndex(0)
            }
            self.checkDistance()
        }
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
        let lastDistance = lastDistances.last
        if lastDistance <= 3.0 {
            self.map.removeFromSuperview()
            self.distanceLabel.removeFromSuperview()
            self.view.addSubview(closeLabel)
            mapOnScreen == false
        } else if lastDistance > 3.0 {
            self.closeLabel.removeFromSuperview()
            self.view.addSubview(map)
            self.view.addSubview(distanceLabel)
            mapOnScreen = true
        }
    }
}
