//
//  ConnectionManager.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-08.
//

import Foundation
import MultipeerConnectivity

class ConnectionManager:NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate{
    var peerID: MCPeerID!
    var p2pSession: MCSession!
    var p2pBrowser: MCNearbyServiceBrowser!
    var previousCoordinates: CGPoint = CGPoint.init()
    var peerName: String = ""

    
    override init(){
        super.init()
        startP2PSession()
        
    }
    func sendMotion(gesture: String) {
        guard !p2pSession.connectedPeers.isEmpty else {
            return
        }
        
        
        DispatchQueue.main.async {
            guard let command = gesture.data(using: String.Encoding.utf8) else {
                return
            }
            try? self.p2pSession.send(command, toPeers: self.p2pSession.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }
    }
    
    func startP2PSession(){
        peerID = MCPeerID.init(displayName: UIDevice.current.name)
        p2pSession = MCSession.init(peer: peerID!)
        p2pSession.delegate = self
        p2pBrowser = MCNearbyServiceBrowser.init(peer: peerID, serviceType: "smartpad")
        p2pBrowser.delegate = self
        p2pBrowser.startBrowsingForPeers()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
       
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
  
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
      
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        peerName = ""
    
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        p2pBrowser.invitePeer(peerID, to: p2pSession, withContext: nil, timeout: TimeInterval(10))
        peerName = peerID.displayName
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
    

    
    
}
