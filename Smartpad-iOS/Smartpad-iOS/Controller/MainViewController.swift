//
//  MainViewController.swift
//  test-ios-trackpad-concept
//
//  Created by alireza azimi on 2022-01-14.
//

import UIKit
import CoreHaptics
import MultipeerConnectivity

/* From https://www.raywenderlich.com/10608020-getting-started-with-core-haptics */

class MainViewController: UIViewController {
    var connectionManager: ConnectionManager?
    var hapticManager: HapticManager?
    var previousCoordinates: CGPoint = CGPoint.init()
    var connStatus: ConnStatus = ConnStatus.Unpaired
    /* For encoding packets */
    let encoder = JSONEncoder()

    @IBOutlet var settingsButton: UIButton!

    /* Connection status-dependent label */
    @IBOutlet var connInfoLabel: UILabel!
    /* "Pair now" button */
    @IBOutlet var pairButton: UIButton!
    /* Spinner shown when broadcasting or attempting to reconnect */
    @IBOutlet var connSpinner: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        /* Setup the connection manager */
        connectionManager = ConnectionManager()
        connectionManager?.mainVC = self
        
        /* Setup the haptic engine */
        hapticManager = HapticManager()

        updateConnInfoUI()
    }

    @IBAction func singleTapRecognizer(_ recognizer: UITapGestureRecognizer) {
        hapticManager?.playTouchRelease()
        let payload = SingleTapPayload()
        let encPayload = try? encoder.encode(payload)
        let packet = GesturePacket(touchType: GestureType.SingleTap, payload: encPayload)

//        print("SingleTap")

        connectionManager?.sendMotion(gesture: packet)
        
    }

    @IBAction func doubleTapRecognizer(_ recognizer: UITapGestureRecognizer) {
        hapticManager?.playTouchRelease()
        let payload = DoubleTapPayload()
        let encPayload = try? encoder.encode(payload)
        let packet = GesturePacket(touchType: GestureType.DoubleTap, payload: encPayload)

//        print("DoubleTap")

        connectionManager?.sendMotion(gesture: packet)
    }

    @IBAction func singlePanRecognizer(_ recognizer: UIPanGestureRecognizer) {
        processPanEvent(recognizer: recognizer, panStarted: GestureType.SinglePanStarted,
                        panChanged: GestureType.SinglePanChanged,
                        panEnded: GestureType.SinglePanEnded)
    }

    @IBAction func doublePanRecognizer(_ recognizer: UIPanGestureRecognizer) {
        processPanEvent(recognizer: recognizer, panStarted: GestureType.DoublePanStarted,
                        panChanged: GestureType.DoublePanChanged,
                        panEnded: GestureType.DoublePanEnded)
    }

    /**
     * @brief Build a pan packet based on the recognizer and send it to the connection manager
     * @param[in] recognizer:     Gesture recognizer
     * @param[in] panStarted:    Packet type to send when a "started" event is detected by the recognizer
     * @param[in] panChanged: Packet type to send when a "changed" event is detected by the recognizer
     * @param[in] panEnded:     Pakcet type to send when an "ended" event is detected by the recognizer
     */
    func processPanEvent(recognizer: UIPanGestureRecognizer, panStarted: GestureType, panChanged: GestureType, panEnded: GestureType) {
        // Get the translation
        let translation = recognizer.translation(in: recognizer.view!)

        var packet: GesturePacket!
        let payload = PanPayload(xTranslation: Float(translation.x),
                                 yTranslation: Float(translation.y))
        let encPayload = try? encoder.encode(payload)

        if (recognizer.state == .began) {
            hapticManager?.playTouchDown()
            packet = GesturePacket(touchType: panStarted, payload: encPayload)
        }
        else if (recognizer.state == .changed) {
            packet = GesturePacket(touchType: panChanged, payload: encPayload)
        }
        else if (recognizer.state == .ended) {
            hapticManager?.playTouchRelease()
            packet = GesturePacket(touchType: panEnded, payload: encPayload)
        }
        else {
            /* An irrelevant case for our purposes */
            return
        }

//        print(packet.touchType!, " - xTrans: ", payload.xTranslation!, " yTrans: ", payload.yTranslation!)

        connectionManager?.sendMotion(gesture: packet)
    }

    @IBAction func pinchRecognizer(_ recognizer: UIPinchGestureRecognizer) {
        var packet: GesturePacket!
        let payload = PinchPayload(scale: Float(recognizer.scale))
        let encPayload = try? encoder.encode(payload)

        if (recognizer.state == .began) {
            packet = GesturePacket(touchType: GestureType.PinchStarted, payload: encPayload)
        }
        else if (recognizer.state == .changed) {
            packet = GesturePacket(touchType: GestureType.PinchChanged, payload: encPayload)
        }
        else if (recognizer.state == .ended) {
            packet = GesturePacket(touchType: GestureType.PinchEnded, payload: encPayload)
        }
        else {
            /* An irrelevant case for our purposes */
            return
        }

        // Reset the scale so that we only get incremental changes
        // in scale throughout a pinch event.
        recognizer.scale = 1.0
        connectionManager?.sendMotion(gesture: packet)
    }
    
    @IBAction func settingsButtonPressed() {
        if (connStatus == ConnStatus.UnpairedAndBroadcasting) {
            /* The settings button is actually a cancel button in this case*/
            connStatus = ConnStatus.Unpaired
            updateConnInfoUI()
        }
        else {
            /* Show settings page */
            let vc = storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
            vc.modalPresentationStyle = .fullScreen

            vc.connStatus = connStatus
            present(vc, animated: true)
        }
    }


    @IBAction func pairButtonPressed() {
        connStatus = ConnStatus.UnpairedAndBroadcasting
        updateConnInfoUI()
        guard let connectionManager = connectionManager else { return }
        connectionManager.startHosting()
    }


    
    /**
     * @brief Updates all of the UI that is related to the current connection status
     */
    func updateConnInfoUI() {
        switch connStatus {
            case ConnStatus.Unpaired:
                settingsButton.setTitle("Settings", for: .normal)

                connInfoLabel.text = "Unpaired"
                connSpinner.isHidden = true
                connSpinner.stopAnimating()
                pairButton.isHidden = false

            case ConnStatus.UnpairedAndBroadcasting:
                /* Use the settings button as a cancel button in this state */
                settingsButton.setTitle("Cancel", for: .normal)

                connInfoLabel.text = "Broadcasting..."
                connSpinner.isHidden = false
                connSpinner.startAnimating()
                pairButton.isHidden = true

            case ConnStatus.PairedAndConnected:
                settingsButton.setTitle("Settings", for: .normal)

                connInfoLabel.text = "Swipe or tap to start"
                connSpinner.isHidden = true
                connSpinner.stopAnimating()
                pairButton.isHidden = true

            case ConnStatus.PairedAndDisconnected:
                settingsButton.setTitle("Settings", for: .normal)

                connInfoLabel.text = "MacOS device not found, attempting to reconnect..."
                connSpinner.isHidden = false
                connSpinner.startAnimating()
                pairButton.isHidden = true
        }

        /* Draw the connection status and the spinner */
        (self.view as! MainView).status = connStatus
        self.view.setNeedsDisplay()
    }
}

