//
//  BaseViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 17.05.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class BaseViewController: UIViewController {
    
    var bgImg = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImg = UIImageView(image: UIImage(named: "LaunchImage"))
        bgImg.frame.origin.x = (self.view.frame.width - bgImg.frame.width)/2
        bgImg.frame.origin.y = (self.view.frame.height - bgImg.frame.height)/2
        bgImg.alpha = 0.3
        self.view.insertSubview(bgImg, atIndex: 0)
    }
}