//
//  ConnStatus.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

/**
 * Connection status types.
 *
 * Required for connection status functional requirement FR15
 */

public enum ConnStatus {
    case Unpaired
    case UnpairedAndBroadcasting
    case PairedAndConnected
    case PairedAndDisconnected
}
