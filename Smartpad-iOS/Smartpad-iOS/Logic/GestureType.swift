//
//  GestureType.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-18.
//

// Documentation on various iOS gesture recognizers:
// Pinch: https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pinch_gestures
//
// Pan:
// https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures
//
//

public enum GestureType: Codable {
    case PinchStarted
    case PinchChanged
    case PinchEnded
    case SinglePanStarted
    case SinglePanChanged
    case SinglePanEnded
    case DoublePanStarted
    case DoublePanChanged
    case DoublePanEnded
    case SingleTap
    case DoubleTap
}
