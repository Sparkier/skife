//
//  RideViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 17.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class RideViewController: UIViewController, CBPeripheralManagerDelegate {
    
    lazy var noBluetoothView = NoBluetoothView()
    var perMan: CBPeripheralManager!
    
    override func viewDidLoad() {
        perMan = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
            self.view.addSubview(noBluetoothView)
        } else {
            noBluetoothView.removeFromSuperview()
        }
    }
}