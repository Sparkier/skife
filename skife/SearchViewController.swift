//
//  SearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class SearchViewController: UIViewController, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
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
        self.peripheral = peripheral
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
}
