//
//  SearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class SearchViewController: RevealBaseViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    
    var centralManager: CBCentralManager!
    var nsTimer: NSTimer!
    var riders = [Rider]()
    var notIncluded = [Double]()
    var peripherals = [CBPeripheral]()
    let noBluetoothView = NoBluetoothView()
    let locationManager = CLLocationManager()
    var locFound = false
    let numbers: NSDictionary = ["United States":"tel://911", "Canada":"tel://911", "Deutschland":"tel://112"]
    
    @IBOutlet weak var beaconsTableView: UITableView!
    @IBOutlet weak var tvNoSignal: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        nsTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("checkRSSI"), userInfo: nil, repeats: true)
        
        self.beaconsTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // Found IPhone
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        // For not getting the same Peripheral twice
        var doubleID = false
        for rider in riders {
            if rider.peripheral!.identifier == peripheral.identifier {
                doubleID = true
            }
        }
        if !doubleID {
            peripherals.append(peripheral)
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // Called When Peripheral gets disconnected, reconnecting it
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    // Called after Peripheral Connected, discovering Services
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "109F17E4-EF68-43FC-957D-502BB0EFCF46")])
    }
    
    // Called When Services are Dicovered, discovering Characteristics
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([CBUUID(string: "F2AF77EC-2F1F-4B20-8075-3E69A4B60C53"),CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004")], forService: service )
        }
    }
    
    // Called When Cahracteristics are Discovered, reading Values
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        peripheral.readValueForCharacteristic(service.characteristics![1] as CBCharacteristic)
    }
    
    // Called When Values are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Identifier Characteristic
        if characteristic.UUID == CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004") {
            if characteristic.value != nil {
                let identifier = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
                let service = peripheral.services![0] as CBService
                let char = service.characteristics![0] as CBCharacteristic
                var existing = false
                for rider in riders {
                    // Rider exists
                    if rider.identifier == identifier as String {
                        existing = true
                        rider.peripheral = peripheral
                        peripheral.readValueForCharacteristic(char)
                    }
                }
                // New Rider
                if !existing {
                    let rider = Rider(identifier: identifier as String, peripheral: peripheral)
                    riders.append(rider)
                    peripheral.readValueForCharacteristic(char)
                }
            }
        }
        // Name Characteristic
        if characteristic.UUID == CBUUID(string: "F2AF77EC-2F1F-4B20-8075-3E69A4B60C53") {
            if characteristic.value != nil {
                let name = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
                for rider in riders {
                    if rider.peripheral == peripheral {
                        rider.name = name as String
                    }
                }
            }
        }
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
            noBluetoothView.removeFromSuperview()
        } else {
            self.view.addSubview(noBluetoothView)
        }
    }
    
    // Table View Specifying how many Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return riders.count
    }
    
    // Table View Generating each Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as UITableViewCell!
        
        let nameLabel:String! = "\(riders[indexPath.row].name)"
        cell.textLabel!.text = nameLabel
        
        if let acc = riders[indexPath.row].accuracy {
            let detailLabel: String = "~ \(round(acc*10.0)/10.0) m"
            cell.detailTextLabel!.text = detailLabel
        } else {
            let detailLabel: String = "Not in Range"
            cell.detailTextLabel!.text = detailLabel
        }
        
        return cell
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("detailedSearchViewController")
        let detailedSearchViewController: DetailedSearchViewController = vc as! DetailedSearchViewController;
        detailedSearchViewController.rider = riders[indexPath.row]
        navigationController?.pushViewController(vc as! UIViewController, animated: true)
    }
    
    // Checks the RSSI of all Peripherals
    func checkRSSI() {
        if riders.count > 0 {
            self.beaconsTableView.hidden = false
            self.tvNoSignal.hidden = true
            for rider in riders {
                if let per = rider.peripheral {
                    per.readRSSI()
                }
            }
            self.beaconsTableView.reloadData()
        } else {
            self.beaconsTableView.hidden = true
            self.tvNoSignal.hidden = false
        }
    }
    
    // Called when the RSSI is getting read
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        for rider in riders {
            if rider.peripheral == peripheral {
                if rider.RSSI == nil {
                    rider.RSSI = Double(RSSI)
                    rider.rollingRSSI = Double(RSSI)
                    rider.accuracy = calculateAccuracy(70.0, rssi: rider.RSSI!)
                } else {
                    rider.rollingRSSI = (Double(RSSI) * 0.2)+(rider.rollingRSSI! * (1.0-0.2))
                    if notIncluded.count == 3 {
                        rider.RSSI = rider.rollingRSSI
                        rider.accuracy = calculateAccuracy(70.0, rssi: rider.rollingRSSI!)
                        notIncluded = []
                    } else {
                        if (rider.rollingRSSI! * 1.5) > rider.RSSI! || (rider.rollingRSSI! * 0.5) < rider.RSSI! {
                            notIncluded.append(Double(RSSI))
                        } else {
                            rider.RSSI = rider.rollingRSSI!
                            rider.accuracy = calculateAccuracy(70.0, rssi: rider.rollingRSSI!)
                            notIncluded = []
                        }
                    }
                }
            }
        }
    }
    
    // Calculates an approximated Accuracy value
    func calculateAccuracy(txPower: Double, rssi: Double) -> Double {
        
        if rssi == 0 {
            return -1.0
        }
        let ratio: Double = rssi*1.0/txPower
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            return ((0.89976) * (pow(ratio,7.7095)) + 0.111)
        }
    }
    
    // Starts LocationManager for getting the correct Number
    @IBAction func emergencyCall(sender: AnyObject) {
        locFound = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Called when Location was found
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                if !self.locFound {
                    self.locFound = true
                    self.makeCall(pm)
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    // Location Error
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    // Checking Number and making Call
    func makeCall(placemark: CLPlacemark) {
        let country = placemark.country != nil ? placemark.country! : ""
        let number = numbers.valueForKey(country) != nil ? numbers.valueForKey(country) as! String : "tel://112"
        
        let url:NSURL = NSURL(string:number)!
        UIApplication.sharedApplication().openURL(url)
    }
}