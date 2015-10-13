//
//  NoBluetoothView.swift
//  skife
//
//  Created by Alex Bäuerle on 15.04.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import UIKit

// View shown when Bluetooth is turned of at several Points in the App
class NoBluetoothView: UIView {
    init() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        super.init(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        // Label indicating to turn on Bluetooth
        let nbLabel = UILabel(frame: CGRectMake(0, screenSize.height-30, screenSize.width, 30))
        nbLabel.text = "Turn on your Bluetooth to continue."
        nbLabel.textAlignment = NSTextAlignment.Center
        nbLabel.textColor = UIColor(red: 102.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        // Bluetooth Logo showing in center
        let nbView = UIImageView(frame: CGRectMake(10, (screenSize.height/2) - ((screenSize.width - 20)/2), screenSize.width-20, screenSize.width-20))
        nbView.image = UIImage(named: "Bluetooth")
        
        self.addSubview(nbLabel)
        self.addSubview(nbView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}