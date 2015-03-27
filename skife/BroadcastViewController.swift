//
//  BroadcastViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 01.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
//import CoreLocation
import CoreBluetooth

class BroadcastViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var myBeaconData: NSDictionary!
    var advertisingData: NSDictionary!
    var perMan: CBPeripheralManager!
    let TRANSFER_SERVICE_UUID = "7521105F-8937-48B7-A875-66E6FE21D714"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        perMan = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // Broadcast when Bluetooth is on
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            let advertisingData: NSDictionary = [CBAdvertisementDataLocalNameKey: "vicinity-peripheral",
                CBAdvertisementDataServiceUUIDsKey: [TRANSFER_SERVICE_UUID]];
            
            // Start advertising over BLE
            self.perMan.startAdvertising(advertisingData)
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            self.perMan.stopAdvertising()
        }
    }
}