//
//  SearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class SearchViewController: BaseViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var nsTimer: NSTimer!
    var riders = [Rider]()
    var rollingRssi: Double = 0.0
    var notIncluded = [Double]()
    var peripherals = [CBPeripheral]()
    lazy var noBluetoothView = NoBluetoothView()
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    @IBOutlet weak var beaconsTableView: UITableView!
    @IBOutlet weak var tvNoSignal: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        nsTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("checkRSSI"), userInfo: nil, repeats: true)
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.beaconsTableView.tableFooterView = UIView(frame: CGRectZero)
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
            peripherals.append(peripheral)
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // Called When Peripheral gets disconnected, reconnecting it
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    // Called after Peripheral Connected, discovering Services
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "109F17E4-EF68-43FC-957D-502BB0EFCF46")])
    }
    
    // Called When Services are Dicovered, discovering Characteristics
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            peripheral.discoverCharacteristics([CBUUID(string: "F2AF77EC-2F1F-4B20-8075-3E69A4B60C53"),CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004")], forService: service as! CBService)
        }
    }
    
    // Called When Cahracteristics are Discovered, reading Values
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        peripheral.readValueForCharacteristic(service.characteristics[1] as! CBCharacteristic)
    }
    
    // Called When Values are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        // Identifier Characteristic
        if characteristic.UUID == CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004") {
            if characteristic.value != nil {
                let identifier = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!
                let service = peripheral.services[0] as! CBService
                let char = service.characteristics[0] as! CBCharacteristic
                var existing = false
                for rider in riders {
                    // Rider exists
                    if rider.identifier == identifier as! String {
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
                let name = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!
                for rider in riders {
                    if rider.peripheral == peripheral {
                        rider.name = name as! String
                    }
                }
            }
        }
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
        
        var nameLabel:String! = "\(riders[indexPath.row].name)"
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
        detailedSearchViewController.rollingRssi = self.rollingRssi
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
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        for rider in riders {
            if rider.peripheral == peripheral && RSSI != nil {
                if rider.RSSI == nil {
                    rider.RSSI = Double(RSSI)
                    rider.accuracy = calculateAccuracy(70.0, rssi: rider.RSSI!)
                }
                rollingRssi = (Double(RSSI) * 0.2)+(rollingRssi * (1.0-0.2))
                if notIncluded.count == 3 {
                    rider.RSSI = rollingRssi
                    rider.accuracy = calculateAccuracy(70.0, rssi: rollingRssi)
                    notIncluded = []
                } else {
                    if (rollingRssi * 1.5) > rider.RSSI || (rollingRssi * 0.5) < rider.RSSI {
                        notIncluded.append(rollingRssi)
                    } else {
                        rider.RSSI = rollingRssi
                        rider.accuracy = calculateAccuracy(70.0, rssi: rollingRssi)
                        notIncluded = []
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
        var ratio: Double = rssi*1.0/txPower
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            return ((0.89976) * (pow(ratio,7.7095)) + 0.111)
        }
    }
    
    // Dial emergency Call
    @IBAction func emergencyCall(sender: AnyObject) {
        let phone = "tel://0049754691091";
        let url:NSURL = NSURL(string:phone)!;
        UIApplication.sharedApplication().openURL(url);
    }
}