//
//  SettingsViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 12.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!

    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "Profile")
        request.returnsObjectsAsFaults = false
        
        var res:NSArray = context.executeFetchRequest(request, error: nil)!
        self.profile = res[0] as! Profile
        nameTextField.text = profile.name
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.profile.name = self.nameTextField.text
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext!
        context.save(nil)
    }
}