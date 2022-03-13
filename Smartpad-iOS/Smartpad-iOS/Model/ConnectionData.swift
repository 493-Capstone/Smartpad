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
    static let deviceUUID = ""
}

class ConnectionData {
    let defaults = UserDefaults.standard
    
    func setSelectedDeviceUUID(uuid: String){
        defaults.set(uuid, forKey: ConnectionKeys.deviceUUID)
    }
    
    func getSelectedDeviceUUID() throws -> String {
        if let deviceUUID = defaults.string(forKey: ConnectionKeys.deviceUUID) {
           return deviceUUID
        } else {
            throw StorageError.ValueNotFoundError
        }
        
    }
}
