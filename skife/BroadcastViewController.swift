//
//  BroadcastViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 01.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class BroadcastViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var myBeaconData: NSDictionary!
    var perMan: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uuid = NSUUID(UUIDString: "7521105F-8937-48B7-A875-66E6FE21D713")
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1, identifier: "testregion")
        perMan = CBPeripheralManager(delegate: self, queue: nil)
        myBeaconData = beaconRegion.peripheralDataWithMeasuredPower(nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            self.perMan.startAdvertising(myBeaconData)
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            self.perMan.stopAdvertising()
        }
    }
}