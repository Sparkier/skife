//
//  SearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class SearchViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var centralManager: CBCentralManager!
    var peripherals = [CBPeripheral]()
    
    @IBOutlet weak var beaconsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Listen to BLE of IPhones
        let services: NSArray = ["7521105F-8937-48B7-A875-66E6FE21D714"]
    }
    
    // Found IPhone
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println(RSSI)
        self.peripherals.append(peripheral)
        beaconsTableView.reloadData()
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    // Table View Specifying how many Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
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
        
        var nameLabel:String! = "\(peripherals[indexPath.row].state)"
        cell!.textLabel!.text = nameLabel
        
        var detailLabel: String = "Not in Range."
        cell!.detailTextLabel!.text = detailLabel
        
        return cell!
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("detailedSearchViewController")
        var detailedSearchViewController: DetailedSearchViewController = vc as! DetailedSearchViewController;
        detailedSearchViewController.rider = riders[indexPath.row]
        navigationController?.pushViewController(vc as! UIViewController, animated: true)*/
    }
}
