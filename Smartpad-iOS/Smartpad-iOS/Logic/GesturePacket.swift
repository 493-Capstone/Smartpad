//
//  GesturePacket.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-18.
//

import Foundation

struct GesturePacket: Codable {
    var touchType: GestureType!
    var payload: Data!
}

struct PinchPayload: Codable {
    var xScale: Float!
    var yScale: Float!
}

struct SingleTapPayload: Codable {
}

struct DoubleTapPayload: Codable {
}
