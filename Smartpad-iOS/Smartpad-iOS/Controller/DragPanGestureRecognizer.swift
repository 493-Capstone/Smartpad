//
//  DragPanGestureRecognizer.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-22.
//

import Foundation
import UIKit

// Portions of this code follow the apple documentation:
// https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/implementing_a_custom_gesture_recognizer/implementing_a_discrete_gesture_recognizer

// Custom gesture for longtouch then drag
// Rules:
// 1. The user must long touch for 1s
// 2. The user must pan

class UIDragPanGestureRecognizer:
    UIGestureRecognizer {
    /* Geture states */
    private enum DragPanPhases {
        case notStarted /* State when we have touched down but not long touched */
        case started /* State when we have long touched but not yet panned */
        case changed /* State when we first started panning */
    }

    /* Current drag pan state */
    private var currentPhase = DragPanPhases.notStarted

    /* Work to be run asynchronously after some time (for detecting long press) */
    // https://stackoverflow.com/questions/44633729/stop-a-dispatchqueue-that-is-running-on-the-main-thread
    private var work: DispatchWorkItem?

    /* Controls length of required time for long touching */
    private let longTouchTime = 1

    /* Initial point we touched. This is used for allowing a small tolerance radius for the 1s long touch */
    var initialPos: CGPoint = CGPoint.zero

    /* Starting position for the dragpan. We reference the translation from dragging with this as the origin */
    var startPos: CGPoint = CGPoint.zero

    /* Translation from the initial point */
    var translation: CGPoint = CGPoint.zero

    /* The touch we are tracking */
    var trackedTouch: UITouch? = nil

    /* For haptic feedback related to the gesture */
    private var hapticManager: HapticManager?

    /* Tolerance for involuntary movement during the long touch */
    var tolerance = CGFloat(10.0)

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        hapticManager = HapticManager()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        /* Only recognizer 1 finger touches */
        if touches.count != 1 {
            self.state = .failed
            return
//            print("Failed, too many touches")
        }


        if self.trackedTouch == nil {
            /* Capture the first touch and store some information about it. */
            self.trackedTouch = touches.first
            self.initialPos = (self.trackedTouch?.location(in: self.view))!
            self.startPos = self.initialPos

            work = DispatchWorkItem(block: {
                self.currentPhase = .started
                self.hapticManager?.playTouchDown()
            })

            /* After 1s, consider the touch to be a "long touch" */
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: work!);
        }
        else {
            /* This is not the first touch, ignore all touches except the first one. */
            for touch in touches {
                if touch != self.trackedTouch {
                    self.ignore(touch, for: event)
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        // Fails if we are tracking some touch other than the initial touch
        let newTouch = touches.first
        if (newTouch != trackedTouch) {
            self.state = .failed
            return
        }

        /* Calculate the translation from the initial touch */
        let newPos = (newTouch?.location(in: self.view))!


        if (currentPhase == .notStarted) {
            /* We started panning before fully ending touching! */

            let distFromInitial = CGPoint(x: newPos.x - initialPos.x,
                                          y: newPos.y - initialPos.y)

            /* Allow for slight, involuntary movements */
            if (abs(distFromInitial.x) > tolerance || abs(distFromInitial.y) > tolerance) {
                self.state = .failed
//                print("Failed, didn't long press before panning")
            }
            else
            {
                /* Update the origin point for panning, otherwise the mouse jumps after the first pan occurs */
                startPos = newPos
//                print("Ignored involuntary movement!")
            }

            return
        }

        translation = CGPoint(x: newPos.x - startPos.x,
                              y: newPos.y - startPos.y)

        currentPhase = .changed
        self.state = .changed
//            print("Changed")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if (currentPhase == .notStarted || currentPhase == .started) {
            /* We released our finger too early or before panning */
            self.state = .failed
//            print("Failed, we released our touch too early or didn't pan")
        }
        else {
            self.state = .recognized
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.state = .cancelled

        resetVars()

//        print("Cancelled")
    }

    override func reset() {
        super.reset()
        resetVars()

//        print("Reset")
    }

    private func resetVars() {
        /* Cancel the timer's work first to avoid race conditions */
        work?.cancel()
        work = nil

        currentPhase = .notStarted
        trackedTouch = nil
        initialPos = CGPoint.zero
        startPos = CGPoint.zero
        translation = CGPoint.zero
    }
}
