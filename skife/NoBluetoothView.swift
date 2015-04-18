//
//  NoBluetoothView.swift
//  skife
//
//  Created by Alex Bäuerle on 15.04.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import UIKit

class NoBluetoothView: UIView {
    init() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        super.init(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        var nbLabel = UILabel(frame: CGRectMake(0, screenSize.height-30, screenSize.width, 30))
        nbLabel.text = "Turn on your Bluetooth to continue."
        nbLabel.textAlignment = NSTextAlignment.Center
        nbLabel.textColor = UIColor(red: 102.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.addSubview(nbLabel)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}