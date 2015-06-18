//
//  RevealBaseViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 18.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class RevealBaseViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let rVC = self.revealViewController() {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Plain, target: rVC, action: "revealToggle:")
            self.view.addGestureRecognizer(rVC.panGestureRecognizer())
        }
    }
}