//
//  MainViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

class MainViewController: BaseViewController, CBPeripheralManagerDelegate {
    
    var perMan: CBPeripheralManager!
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perMan = CBPeripheralManager(delegate: self, queue: nil)
        
        // Initial setup after first App Launch
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey("hasLaunchedOnce") {
            let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDel.managedObjectContext!
                
            let entProfile = NSEntityDescription.entityForName("Profile", inManagedObjectContext: context)
            var defaultBg = Profile(entity: entProfile!, insertIntoManagedObjectContext: context)
            let device = UIDevice.currentDevice()
            defaultBg.name = device.name
            context.save(nil)
            defaults.setBool(true, forKey: "hasLaunchedOnce")
            defaults.synchronize()
        }
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Just for Notifying the User when Bluetooth is turned off
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
    }
}