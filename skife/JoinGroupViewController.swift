//
//  JoinGroupViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit

class JoinGroupViewController: UIViewController, MPCManagerPeerDelegate {
    
    var mpcManager: MPCManager = MPCManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mpcManager.delegatePeer = self
        mpcManager.advertiser.startAdvertisingPeer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        mpcManager.advertiser.stopAdvertisingPeer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to invite you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mpcManager.invitationHandler(true, self.mpcManager.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.mpcManager.invitationHandler(false, nil)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
