//
//  BroadcastViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 01.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

class BroadcastViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var perMan: CBPeripheralManager!
    let myCustomServiceUUID: CBUUID = CBUUID(string: "109F17E4-EF68-43FC-957D-502BB0EFCF46")
    var myService: CBMutableService!
    lazy var noBluetoothView = NoBluetoothView()
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perMan = CBPeripheralManager(delegate: self, queue: nil)
        myService = CBMutableService(type: myCustomServiceUUID, primary: true)
        
        // Getting Username
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: "Profile")
        request.returnsObjectsAsFaults = false
        var res:NSArray = context.executeFetchRequest(request, error: nil)!
        let profile = res[0] as! Profile
        
        // Setting up Name Characteristic
        var myCharacteristic: CBCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "F2AF77EC-2F1F-4B20-8075-3E69A4B60C53"), properties: CBCharacteristicProperties.Read, value: profile.name.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), permissions: CBAttributePermissions.Readable)
        
        // Setting up Name Characteristic
        let identifier = UIDevice.currentDevice().identifierForVendor
        var myIdentifierCharacteristic: CBCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004"), properties: CBCharacteristicProperties.Read, value: identifier.UUIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), permissions: CBAttributePermissions.Readable)
        
        myService.characteristics = [myCharacteristic, myIdentifierCharacteristic]
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // Broadcast when Bluetooth is on
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            // Start advertising over BLE
            self.perMan.addService(myService)
            self.perMan.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [myService.UUID]])
            self.noBluetoothView.removeFromSuperview()
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            self.perMan.stopAdvertising()
            self.view.addSubview(noBluetoothView)
        }
    }
}