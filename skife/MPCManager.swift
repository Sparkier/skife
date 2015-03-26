//
//  MPCManager.swift
//  skife
//
//  Created by Alex Bäuerle on 26.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

protocol MPCManagerBrowserDelegate {
    func foundPeer()
    func lostPeer(peerID: MCPeerID)
    func connectedWithPeer(peerID: MCPeerID)
    func disConnectedWithPeer(peerID: MCPeerID)
}

protocol MPCManagerPeerDelegate {
    func invitationWasReceived(fromPeer: String)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    var invitationHandler: ((Bool, MCSession!)->Void)!

    var delegateBrowser: MPCManagerBrowserDelegate?
    var delegatePeer: MPCManagerPeerDelegate?
    var foundPeers = [MCPeerID]()
    var profile: Profile!
    
    override init() {
        super.init()
        
        // Get Profile Name
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: "Profile")
        request.returnsObjectsAsFaults = false
        var res:NSArray = context.executeFetchRequest(request, error: nil)!
        self.profile = res[0] as Profile
        
        // Set up Peer
        peer = MCPeerID(displayName: profile.name)
        session = MCSession(peer: peer)
        session.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "skife")
        browser.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "skife")
        advertiser.delegate = self
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        foundPeers.append(peerID)
        delegateBrowser?.foundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        for (index, aPeer) in enumerate(foundPeers){
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        delegateBrowser?.lostPeer(peerID)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        self.invitationHandler = invitationHandler
        delegatePeer?.invitationWasReceived(peerID.displayName)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println(error.localizedDescription)
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:
            delegateBrowser?.connectedWithPeer(peerID)
        case MCSessionState.Connecting:
            break
        default:
            self.delegateBrowser?.disConnectedWithPeer(peerID)
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let dictionary: [String: AnyObject] = ["data": data, "fromPeer": peerID]
        NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) { }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let peersArray = NSArray(object: targetPeer)
        var error: NSError?
        
        if !session.sendData(dataToSend, toPeers: peersArray, withMode: MCSessionSendDataMode.Reliable, error: &error) {
            println(error?.localizedDescription)
            return false
        }
        return true
    }
}
