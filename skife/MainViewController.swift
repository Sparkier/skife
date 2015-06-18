//
//  MainViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: RevealBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}