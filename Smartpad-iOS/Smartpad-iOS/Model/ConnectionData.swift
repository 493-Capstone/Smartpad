//
//  ConnectionData.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-13.
//

import Foundation
enum StorageError: Error {
    case ValueNotFoundError
}
struct ConnectionKeys {
    static let connDeviceUUID = ""
    static let currDeviceName = ""
}

class ConnectionData {
    let defaults = UserDefaults.standard
    
    func setSelectedDeviceUUID(uuid: String){
        defaults.set(uuid, forKey: ConnectionKeys.connDeviceUUID)
        defaults.synchronize()
    }
    
    func getSelectedDeviceUUID() -> String {
        if let deviceUUID = defaults.string(forKey: ConnectionKeys.connDeviceUUID) {
           return deviceUUID
        } else {
            return ""
        }
        
    }
    
    func getDeviceName() -> String{
        if let deviceName = defaults.string(forKey: ConnectionKeys.currDeviceName) {
           return deviceName
        } else {
   
           return ""
        }
    }
    
    func setDeviceName(name: String){
        defaults.set(name, forKey: ConnectionKeys.currDeviceName)
        defaults.synchronize()
    }

}
