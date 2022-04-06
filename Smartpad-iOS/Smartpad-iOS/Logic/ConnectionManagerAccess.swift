//
//  ConnectionManagerAccess.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-30.
//

/**
 * Creates singleton access to the connection manager.
 *
 * Required for connectivity functional requirements (FR1-FR4)
 */

import Foundation

struct ConnectionManagerAccess {
    static var connectionManager = ConnectionManager()
}
