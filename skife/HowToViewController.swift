//
//  HowToViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 04.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class HowToViewController: BaseViewController {
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
