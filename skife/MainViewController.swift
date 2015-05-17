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
            var inputTextField: UITextField?
            let namePrompt = UIAlertController(title: "Enter Username", message: "You need to enter your username.", preferredStyle: UIAlertControllerStyle.Alert)
            namePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                let context = appDel.managedObjectContext!
                
                let entProfile = NSEntityDescription.entityForName("Profile", inManagedObjectContext: context)
                var defaultBg = Profile(entity: entProfile!, insertIntoManagedObjectContext: context)
                defaultBg.name = inputTextField!.text
                context.save(nil)
                defaults.setBool(true, forKey: "hasLaunchedOnce")
                defaults.synchronize()
            }))
            namePrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Name"
                inputTextField = textField
            })
            presentViewController(namePrompt, animated: true, completion: nil)
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