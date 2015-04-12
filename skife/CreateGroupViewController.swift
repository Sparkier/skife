//
//  CreateGroupViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 25.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerBrowserDelegate {
    var mpcManager: MPCManager = MPCManager()
    var connectedPeers: [MCPeerID] = []
    
    @IBOutlet weak var tblPeers: UITableView!
    
    override func viewDidLoad() {
        mpcManager.delegateBrowser = self
        mpcManager.browser.startBrowsingForPeers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        mpcManager.browser.stopBrowsingForPeers()
    }
    
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    func lostPeer(peerID: MCPeerID) {
        self.disConnectedWithPeer(peerID)
        tblPeers.reloadData()
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        connectedPeers.append(peerID)
        tblPeers.reloadData()
    }
    
    func disConnectedWithPeer(peerID: MCPeerID) {
        for var i = 0; i < connectedPeers.count; i++ {
            if connectedPeers[i] == peerID {
                connectedPeers.removeAtIndex(i)
                i = connectedPeers.count + 1
            }
        }
        tblPeers.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mpcManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellPeer") as! UITableViewCell
        if contains(connectedPeers, mpcManager.foundPeers[indexPath.row]) {
            cell.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
        }
        cell.textLabel?.text = mpcManager.foundPeers[indexPath.row].displayName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = mpcManager.foundPeers[indexPath.row] as MCPeerID
        mpcManager.browser.invitePeer(selectedPeer, toSession: mpcManager.session, withContext: nil, timeout: 20)
        tblPeers.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
