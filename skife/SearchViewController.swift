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
    
    // Send Notifications on Beacon actions
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // Ranged Beacon by Location Manager
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!,inRegion region: CLBeaconRegion!) {
        // Updating Beacon of Rider
        for rider in riders {
            if region.proximityUUID == rider.beaconUUID {
                if beacons.count > 0 {
                    rider.beacon = beacons[0] as? CLBeacon
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
        return riders.count
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
        
        let beacon:CLBeacon? = riders[indexPath.row].beacon
        var nameLabel:String! = riders[indexPath.row].name
        
        cell!.textLabel!.text = nameLabel
        
        var detailLabel: String = "Not in Range."
        if let b = beacon {
            if b.accuracy == -1 {
                detailLabel = "Distance could not be Calculated."
            } else {
                detailLabel = "About \(round(10*b.accuracy)/10) meters."
            }
        }
        cell!.detailTextLabel!.text = detailLabel
        
        return cell!
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("detailedSearchViewController")
        var detailedSearchViewController: DetailedSearchViewController = vc as DetailedSearchViewController;
        detailedSearchViewController.rider = riders[indexPath.row]
        navigationController?.pushViewController(vc as UIViewController, animated: true)
    }
}

