//
//  ConnectionManager.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-08.
//

import Foundation
import MultipeerConnectivity

class ConnectionManager:NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate{

    
    var peerID: MCPeerID!
    var p2pSession: MCSession?
    var p2pBrowser: MCNearbyServiceBrowser!
    var previousCoordinates: CGPoint = CGPoint.init()
    var advertiser: MCNearbyServiceAdvertiser?
    var peerName: String = ""
    var mainVC: MainViewController!

    
    override init(){
        super.init()
        
        startP2PSession()
    }
    func sendMotion(gesture: GesturePacket) {
        guard let p2pSession = p2pSession else {return}
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
            guard let p2pSession = self.p2pSession else {return}
            try? p2pSession.send(command, toPeers: p2pSession.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }
    }
    
    /**
            This method starts broadcasting for peers
     */
    func startP2PSession(){
        let connData = ConnectionData()
        peerID = MCPeerID.init(displayName: connData.getDeviceName())
        p2pSession = MCSession.init(peer: peerID!, securityIdentity: nil, encryptionPreference: .required)
        p2pSession?.delegate = self

    }
    
    
    func startHosting(){
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "smartpad")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    func stopHosting(){
        advertiser?.stopAdvertisingPeer()
    }

}

extension ConnectionManager{
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                print("Connected: \(peerID.displayName)")
                mainVC.connStatus = ConnStatus.PairedAndConnected
                self.advertiser?.stopAdvertisingPeer()
                DispatchQueue.main.async {
                    self.mainVC.updateConnInfoUI()
                    
                }
                
            case .connecting:
                print("Connecting: \(peerID.displayName)")
                mainVC.connStatus = ConnStatus.PairedAndDisconnected
                DispatchQueue.main.async {
                    self.mainVC.updateConnInfoUI()
                    
                }
            case .notConnected:
                print("notConnected: \(peerID.displayName)")
                mainVC.connStatus = ConnStatus.Unpaired
                advertiser?.stopAdvertisingPeer()
                DispatchQueue.main.async {
                    self.mainVC.updateConnInfoUI()
                    
                }
        @unknown default:
            print("unknown state")
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // creates dialog box to accept or reject the connection request
        let ac = UIAlertController(title: "Smartpad", message: "'\(peerID.displayName)' wants to connect", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
            invitationHandler(true, self?.p2pSession)
        }))
        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
        }))
        mainVC.present(ac, animated: true)
    }
}
