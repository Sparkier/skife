//
//  BroadcastViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 01.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class BroadcastViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var perMan: CBPeripheralManager!
    let myCustomServiceUUID: CBUUID = CBUUID(string: "109F17E4-EF68-43FC-957D-502BB0EFCF46")
    var myService: CBMutableService!
    lazy var noBluetoothView = NoBluetoothView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perMan = CBPeripheralManager(delegate: self, queue: nil)
        myService = CBMutableService(type: myCustomServiceUUID, primary: true)
        perMan.addService(myService)
    }
    
    // Broadcast when Bluetooth is on
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            // Start advertising over BLE
            self.perMan.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [myService.UUID]])
            self.noBluetoothView.removeFromSuperview()
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            self.perMan.stopAdvertising()
            self.view.addSubview(noBluetoothView)
        }
    }
}