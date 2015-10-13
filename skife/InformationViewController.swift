//
//  InformationViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 15.04.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreData

class InformationViewController: RevealBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "Profile")
        request.returnsObjectsAsFaults = false
        
        let res:NSArray = try! context.executeFetchRequest(request)
        self.profile = res[0] as! Profile
        nameTextField.text = profile.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.profile.name = self.nameTextField.text!
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext!
        do {
            try context.save()
        } catch _ {
        }
    }
    
    // TextField Return Press
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return false
    }
}
