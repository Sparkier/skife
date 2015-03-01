
//
//  Contact.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import CoreLocation

class Rider {
    var name: String
    var uuid: String
    var beaconUUID: NSUUID
    var beaconRegion: CLBeaconRegion
    
    init (name: String, uuid:String) {
        self.name = name
        self.uuid = uuid
        beaconUUID = NSUUID(UUIDString: uuid)!
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: name)
    }
}