//
//  ConnectionManager.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-08.
//

import Foundation
import MultipeerConnectivity

/**
 * ConnectionManager handles connectivity states, pairing, and sending/receiving messages.
 *
 * Required for Device Pairing (FR1-FR4), and required for Connection Status (FR15 & FR16)
 */
class ConnectionManager:NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate{
    
    private var peerID: MCPeerID!
    private var p2pSession: MCSession?
    private var p2pBrowser: MCNearbyServiceBrowser!
    private var previousCoordinates: CGPoint = CGPoint.init()
    private var advertiser: MCNearbyServiceAdvertiser?
    var mainVC: MainViewController!
    private var connStatus = ConnStatus.Unpaired
    
    override init(){
        super.init()
        
        startP2PSession()
    }
    
    /**
     * method handles sending messages to device.
     * Parameter GesturePacket: Value of type GesturePacket to send
     */
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
            guard let p2pSession = self.p2pSession else {return}
            try? p2pSession.send(command, toPeers: p2pSession.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }
    }
    
    /**
     * method initializss MCSession objects. Does not advertise.
     */
    func startP2PSession(){
        let connData = ConnectionData()
        peerID = MCPeerID.init(displayName: connData.getDeviceName() + "|" + connData.getCurrentDeviceUUID())
        p2pSession = MCSession.init(peer: peerID!, securityIdentity: nil, encryptionPreference: .required)
        p2pSession?.delegate = self
    }
    
    /**
     * method disconnects peer from session
     */
    func stopP2PSession() {
        guard let p2pSession = p2pSession else {
            return
        }
        
        p2pSession.disconnect()
    }
    
    /**
     * Restart the peer-to-peer session. Since the display name cannot be changed while the session
     * is running, this is required whenever we wish to update our display name.
     */
    func restartP2PSession() {
        stopP2PSession()
        startP2PSession()
    }
    
    /**
     * Start advertising for nearby devices
     */
    func startHosting(){
        restartP2PSession()
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "smartpad")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        if (ConnectionData().getSelectedPeer() == "") {
            /* We have no peer, which means we are advertising to try to find a peer */
            connStatus = .UnpairedAndBroadcasting
        }
        else {
            /* We have a peer, which means we are disconnected and trying to reconnect */
            connStatus = .PairedAndDisconnected
        }
        
        mainVC?.updateConnInfoUI()
    }
    
    /**
     * Stop advertising for nearby devices
     */
    func stopHosting(){
        advertiser?.stopAdvertisingPeer()
        connStatus = .Unpaired
        mainVC?.updateConnInfoUI()
    }
    
    /**
     * Unpairs and disconnects the device
     */
    func unpairDevice(){
        guard let p2pSession = p2pSession else {
            return
        }
        
        let connData = ConnectionData()
        connData.setSelectedPeer(name: "")
        p2pSession.disconnect()
        advertiser?.stopAdvertisingPeer()
        
        connStatus = .Unpaired
        mainVC?.updateConnInfoUI()
    }
    
    /**
     * @brief get the current connection status
     */
    func getConnStatus() -> ConnStatus {
        return connStatus
    }
}

extension ConnectionManager{
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used
    }
    
    /**
     * Session delegate for handling connection status (connected, not connected, connecting)
     */
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            let connData = ConnectionData()
            connData.setSelectedPeer(name: peerID.displayName)
            connStatus = ConnStatus.PairedAndConnected
            self.advertiser?.stopAdvertisingPeer()
            self.mainVC.updateConnInfoUI()
            
        case .connecting:
            break
            
        case .notConnected:
            /* We are still paired, just lost connection. Update the UI to indicate that we are attempting to reconnect */
            let connData = ConnectionData()
            if(connData.getSelectedPeer() != ""){
                if(p2pSession?.connectedPeers.count == 0){
                    // Ensure no peers are connected
                    connStatus = ConnStatus.PairedAndDisconnected
                    advertiser?.startAdvertisingPeer()
                    self.mainVC.updateConnInfoUI()
                }
            } else {
                connStatus = ConnStatus.Unpaired
                advertiser?.stopAdvertisingPeer()
                self.mainVC.updateConnInfoUI()
            }
            
            
        @unknown default:
            print("unknown state")
            
        }
    }
    
    /**
     * Delegate handles data received
     */
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
#if LATENCY_TEST_SUITE
        /* We only expect to receive messages from the host when latency testing, just return the packet to sender */
        DispatchQueue.main.async {
            guard let p2pSession = self.p2pSession else {return}
            try? p2pSession.send(data, toPeers: p2pSession.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }
#endif // LATENCY_TEST_SUITE
    }
    
    /**
     * Delegate method handles invitations to connect from nearby peers
     */
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // creates dialog box to accept or reject the connection request
        let connData = ConnectionData()
        if(connData.getSelectedPeer() != ""){
            if(connData.getSelectedPeer() == peerID.displayName){
                // accept invite and return
                invitationHandler(true, self.p2pSession)
                
                return
            }
        }
        
        let ac = UIAlertController(title: "Smartpad", message: "'\(peerID.displayName.components(separatedBy: "|")[0])' wants to connect", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
            invitationHandler(true, self?.p2pSession)
        }))
        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
        }))
        mainVC.present(ac, animated: true)
    }
}
