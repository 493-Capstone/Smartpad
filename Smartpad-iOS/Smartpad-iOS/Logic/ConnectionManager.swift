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
    }
    func sendMotion(gesture: GesturePacket) {
        guard !p2pSession.connectedPeers.isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            guard let command = try? encoder.encode(gesture)
            else {
                print("[ConnectionManager] Failed to encode packet!")
                return
            }

//          UNCOMMENT TO SEE ENCODED PACKET AS STRING :-)
//            print(String(data: command, encoding: String.Encoding.utf8))

            try? self.p2pSession.send(command, toPeers: self.p2pSession.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }
    }
    
    /**
            This method starts broadcasting for peers
     */
    func startP2PBroadcast(){
        let connData = ConnectionData()
        peerID = MCPeerID.init(displayName: connData.getDeviceName())
        p2pSession = MCSession.init(peer: peerID!)
        p2pSession.delegate = self
        p2pBrowser = MCNearbyServiceBrowser.init(peer: peerID, serviceType: "smartpad")
        p2pBrowser.delegate = self
        p2pBrowser.startBrowsingForPeers()
    }
    func stopP2PBroadCast(){
        p2pBrowser.stopBrowsingForPeers()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
       
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        guard let packet = try? decoder.decode(GesturePacket.self, from: data)
        else {
            print("[ConnectionManager] Failed to decode packet!")
            return
        }
        print(packet)
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
