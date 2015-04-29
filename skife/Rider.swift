
//
//  Contact.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import CoreBluetooth

// Rider = Someone burrowed
class Rider {
//    var name: String
//    var uuid: String
//    var beaconUUID: NSUUID
    var peripheral: CBPeripheral?
    var RSSI: Double?
    var accuracy: Double?
    
    init () {
    }
}