//
//  InformationViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 15.04.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit

class InformationViewController: BaseViewController {

    @IBOutlet weak var bbMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
