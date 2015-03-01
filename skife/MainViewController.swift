//
//  MainViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var perMan: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perMan = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
    }
}