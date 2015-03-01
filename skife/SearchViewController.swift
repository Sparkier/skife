//
//  SearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var locationManager: CLLocationManager?
    var riders = [Rider]()
    var detections = [(Rider, CLBeacon)]()
    
    @IBOutlet weak var beaconsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Riders
        let riderQualcomm = Rider(name: "QualcommBeacon", uuid: "D8FF5C06-7D34-445B-B382-822E98849F18")
        let riderAlina = Rider(name: "Alina Handy", uuid: "4B5F4BC9-BCBD-44BC-85BE-2B80E91BAD34")
        riders.append(riderQualcomm)
        riders.append(riderAlina)
        
        // Set up Location Manager
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        // Listen to each Rider
        for rider in riders {
            locationManager!.startMonitoringForRegion(rider.beaconRegion)
            locationManager!.startRangingBeaconsInRegion(rider.beaconRegion)
        }
        locationManager!.startUpdatingLocation()
    }
    
    // Send Notifications on Beacon found
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // Ranged Beacon by Location Manager
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!,inRegion region: CLBeaconRegion!) {
        var message:String = ""
        
        // Deleting Beacon if already There
        if detections.count > 0 {
            for i in 0...(detections.count-1) {
                if region.proximityUUID == detections[i].0.beaconUUID {
                    detections.removeAtIndex(i)
                    break
                }
            }
        }
        // Adding Beacon to Detected List
        if(beacons.count > 0) {
            for rider in self.riders {
                if rider.beaconUUID == region.proximityUUID {
                    self.detections.append((rider, beacons[0] as CLBeacon))
                }
            }
        }
        beaconsTableView.reloadData()
    }
    
    // Beacon did Enter to Location Manager
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        manager.startUpdatingLocation()
        sendLocalNotificationWithMessage("You entered the region")
    }
    
    // Beacon did Exit of Location Manager
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
        manager.stopUpdatingLocation()
        sendLocalNotificationWithMessage("You exited the region")
    }
    
    // Table View Specifying how many Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detections.count
    }
    
    // Table View Generating each Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? =
        tableView.dequeueReusableCellWithIdentifier("MyIdentifier") as? UITableViewCell
        
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: "MyIdentifier")
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        let beacon:CLBeacon = detections[indexPath.row].1
        var nameLabel:String! = detections[indexPath.row].0.name
        
        cell!.textLabel!.text = nameLabel
        
        let detailLabel:String = "About \(round(10*beacon.accuracy)/10) meters"
        cell!.detailTextLabel!.text = detailLabel
        
        return cell!
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("detailedSearchViewController")
        var detailedSearchViewController: DetailedSearchViewController = vc as DetailedSearchViewController;
        detailedSearchViewController.rider = detections[indexPath.row].0
        navigationController?.pushViewController(vc as UIViewController, animated: true)
    }
}

