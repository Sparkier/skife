//
//  SearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class SearchViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var nsTimer: NSTimer!
    var riders = [Rider]()
    lazy var noBluetoothView = NoBluetoothView()
    
    @IBOutlet weak var beaconsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        nsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("checkRSSI"), userInfo: nil, repeats: true)
    }
    
    // Found IPhone
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        // For not getting the same Peripheral twice
        var doubleID = false
        for rider in riders {
            if rider.peripheral!.identifier == peripheral.identifier {
                doubleID = true
            }
        }
        if !doubleID {
            let rider = Rider()
            rider.peripheral = peripheral
            rider.RSSI = RSSI
            self.riders.append(rider)
            peripheral.delegate = self
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // Called When Peripheral gets disconnected, reconnecting it
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        for i in 0..<riders.count {
            if riders[i].peripheral == peripheral {
                riders.removeAtIndex(i)
            }
        }
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
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
        var cell:UITableViewCell? =
        tableView.dequeueReusableCellWithIdentifier("MyIdentifier") as? UITableViewCell
        
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: "MyIdentifier")
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        var nameLabel:String! = "\(riders[indexPath.row].peripheral!.name)"
        cell!.textLabel!.text = nameLabel
        
        if let acc = riders[indexPath.row].accuracy {
            var detailLabel: String = "~ \(round(acc*10.0)/10.0) m"
            cell!.detailTextLabel!.text = detailLabel
        } else {
            var detailLabel: String = "Not in Range"
            cell!.detailTextLabel!.text = detailLabel
        }
        
        return cell!
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("detailedSearchViewController")
        var detailedSearchViewController: DetailedSearchViewController = vc as! DetailedSearchViewController;
        detailedSearchViewController.rider = riders[indexPath.row]
        navigationController?.pushViewController(vc as! UIViewController, animated: true)
    }
    
    // Checks the RSSI of all Peripherals
    func checkRSSI() {
        for rider in riders {
            if let per = rider.peripheral {
                per.readRSSI()
            }
        }
        self.beaconsTableView.reloadData()
    }
    
    // Called when the RSSI is getting read
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        for rider in riders {
            if rider.peripheral == peripheral {
                rider.RSSI = RSSI
                rider.accuracy = calculateAccuracy(50.0, rssi: Double(RSSI))
            }
        }
    }
    
    // Calculates an approximated Accuracy value
    func calculateAccuracy(txPower: Double, rssi: Double) -> Double {
        if rssi == 0 {
            return -1.0
        }
        var ratio: Double = rssi*1.0/txPower
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            return ((0.89976) * (pow(ratio,7.7095)) + 0.111)
        }
    }
}
