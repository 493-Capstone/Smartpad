//
//  MainViewController.swift
//  test-ios-trackpad-concept
//
//  Created by alireza azimi on 2022-01-14.
//

/**
 * Main view controller. Controls the main application view.
 *
 * Required for all iOS functional requirements.
 *
 * Required for user interface requirements UIR-3 (device pairing UI), and UIR-4 (sending gesture data)
 */

import UIKit
import CoreHaptics
import MultipeerConnectivity

class MainViewController: UIViewController {
    private var connectionManager: ConnectionManager?
    var hapticManager: HapticManager?
    var previousCoordinates: CGPoint = CGPoint.init()
    /* For encoding packets */
    let encoder = JSONEncoder()

    @IBOutlet var settingsButton: UIButton!

    /* Connection status-dependent label */
    @IBOutlet var connInfoLabel: UILabel!
    /* "Pair now" button */
    @IBOutlet var pairButton: UIButton!
    /* Spinner shown when broadcasting or attempting to reconnect */
    @IBOutlet var connSpinner: UIActivityIndicatorView!

    
    // gesture recognizers
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var singleTapDoubleClickGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var singlePanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var doublePanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var dragPanGestureRecognizer: UIGestureRecognizer!
    @IBOutlet var singleTouchGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var doubleTouchGestureRecognizer: UILongPressGestureRecognizer!

    /**
     * @brief Called when the main view is initially loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "mainView"

        /* Setup the connection manager */
        connectionManager = ConnectionManagerAccess.connectionManager
        connectionManager?.mainVC = self
        let connData = ConnectionData()
        if (connData.getSelectedPeer() != "") {
            connectionManager?.startHosting()
        }

        /* Setup the haptic engine */
        hapticManager = HapticManager()

        updateConnInfoUI()
    }

    /**
     * @brief Event listener for whenever a touch occurs. Plays haptic events whenever a touch starts
     * or ends.
     */
    @IBAction func touchRecognizer(_ recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == .began) {
            hapticManager?.playTouchDown()
        }
        else if (recognizer.state == .ended) {
            hapticManager?.playTouchRelease()
        }
    }

    /**
     * @brief Event listener for single-tap gestures. Required for functional requirement FR5
     */
    @IBAction func singleTapRecognizer(_ recognizer: UITapGestureRecognizer) {
        let payload = SingleTapPayload()
        let encPayload = try? encoder.encode(payload)
        let packet = GesturePacket(touchType: GestureType.SingleTap, payload: encPayload)
        connectionManager?.sendMotion(gesture: packet)
    }

    /**
     * @brief Event listener for two concurrent single-taps gestures. Required for functional requirement FR5
     */
    @IBAction func singleTapDoubleClickRecognizer(_ recognizer: UITapGestureRecognizer) {
        let payload = SingleTapDoubleClickPayload()
        let encPayload = try? encoder.encode(payload)
        let packet = GesturePacket(touchType: GestureType.SingleTapDoubleClick, payload: encPayload)
        connectionManager?.sendMotion(gesture: packet)
    }

    /**
     * @brief Event listener for two-finger tap gestures. Required for functional requirement FR6
     */
    @IBAction func doubleTapRecognizer(_ recognizer: UITapGestureRecognizer) {
        let payload = DoubleTapPayload()
        let encPayload = try? encoder.encode(payload)
        let packet = GesturePacket(touchType: GestureType.DoubleTap, payload: encPayload)
        connectionManager?.sendMotion(gesture: packet)
    }

    /**
     * @brief Event listener for single-finger pan. Required for functional requirement FR8
     */
    @IBAction func singlePanRecognizer(_ recognizer: UIPanGestureRecognizer) {
        processPanEvent(recognizer: recognizer, panStarted: GestureType.SinglePanStarted,
                        panChanged: GestureType.SinglePanChanged,
                        panEnded: GestureType.SinglePanEnded)
    }

    /**
     * @brief Event listener for double-finger pan. Required for functional requirement FR9
     */
    @IBAction func doublePanRecognizer(_ recognizer: UIPanGestureRecognizer) {
        processPanEvent(recognizer: recognizer, panStarted: GestureType.DoublePanStarted,
                        panChanged: GestureType.DoublePanChanged,
                        panEnded: GestureType.DoublePanEnded)
    }

    /**
     * @brief Build a pan packet based on the recognizer and send it to the connection manager
     *
     * @param[in] recognizer:     Gesture recognizer
     * @param[in] panStarted:     Packet type to send when a "started" event is detected by the recognizer
     * @param[in] panChanged:     Packet type to send when a "changed" event is detected by the recognizer
     * @param[in] panEnded:       Packet type to send when an "ended" event is detected by the recognizer
     */
    func processPanEvent(recognizer: UIPanGestureRecognizer, panStarted: GestureType, panChanged: GestureType, panEnded: GestureType) {
        // Get the translation
        let translation = recognizer.translation(in: recognizer.view!)

        var packet: GesturePacket!
        let payload = PanPayload(xTranslation: Float(translation.x),
                                 yTranslation: Float(translation.y))
        let encPayload = try? encoder.encode(payload)

        if (recognizer.state == .began) {
            packet = GesturePacket(touchType: panStarted, payload: encPayload)
        }
        else if (recognizer.state == .changed) {
            packet = GesturePacket(touchType: panChanged, payload: encPayload)
        }
        else if (recognizer.state == .ended) {
            packet = GesturePacket(touchType: panEnded, payload: encPayload)
        }
        else {
            /* An irrelevant case for our purposes */
            return
        }

        connectionManager?.sendMotion(gesture: packet)
    }

    /**
     * @brief Event listener for pinch gestures. Required for functional requirement FR10
     */
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

        // Reset the scale so that we only get incremental changes in scale throughout a pinch event.
        recognizer.scale = 1.0
        connectionManager?.sendMotion(gesture: packet)
    }

    /**
     * @brief Event listener for drag pan gestures. Required for functional requirement FR7
     */
    @IBAction func dragPanRecognizer(_ recognizer: UIDragPanGestureRecognizer) {
        // Get the translation

        var packet: GesturePacket!
        let payload = PanPayload(xTranslation: Float(recognizer.translation.x),
                                 yTranslation: Float(recognizer.translation.y))
        let encPayload = try? encoder.encode(payload)

        if (recognizer.state == .began) {
            packet = GesturePacket(touchType: .DragPanStarted, payload: encPayload)
        }
        else if (recognizer.state == .changed) {
            packet = GesturePacket(touchType: .DragPanChanged, payload: encPayload)
        }
        else if (recognizer.state == .ended) {
            packet = GesturePacket(touchType: .DragPanEnded, payload: encPayload)
        }
        else {
            /* An irrelevant case for our purposes */
            return
        }

        connectionManager?.sendMotion(gesture: packet)
    }

    /**
     * @brief Callback for when the settings button is pressed. When we are broadcasting,
     * this acts as a cancel button
     */
    @IBAction func settingsButtonPressed() {
        let connStatus = connectionManager?.getConnStatus()

        if (connStatus == .UnpairedAndBroadcasting) {
            /* The settings button is actually a cancel button in this case */
            connectionManager?.stopHosting()
        }
        else {
            /* Show settings page */
            let vc = storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
            vc.modalPresentationStyle = .fullScreen

            vc.connStatus = connStatus
            present(vc, animated: true)
        }
    }

    /**
     * @brief Callback for when the pair button is pressed
     */
    @IBAction func pairButtonPressed() {
        guard let connectionManager = connectionManager else { return }
        connectionManager.startHosting()
    }

    /**
     * @brief Disables or enables all gesture recognizers
     *
     * @param[in] bool Whether gestures should be recognized
     */
    func shouldRecognizeGestures(enabled: Bool) {
#if LATENCY_TEST_SUITE
        /* For latency testing, we disable all gesture recognizers */
        for recognizer in self.view.gestureRecognizers! {
            recognizer.isEnabled = false
        }
#else
        for recognizer in self.view.gestureRecognizers! {
            recognizer.isEnabled = enabled
        }
#endif // LATENCY_TEST_SUITE
    }

    /**
     * @brief Updates all of the UI that is related to the current connection status
     */
    func updateConnInfoUI() {
        guard let connectionManager = connectionManager else { return }

        DispatchQueue.main.async {
            switch connectionManager.getConnStatus() {
                case ConnStatus.Unpaired:
                    self.settingsButton.setTitle("Settings", for: .normal)

                    self.connInfoLabel.text = "Unpaired"
                    self.connSpinner.isHidden = true
                    self.connSpinner.stopAnimating()
                    self.pairButton.isHidden = false

                    /* Can't send gesture data when disconnected */
                    self.shouldRecognizeGestures(enabled: false)

                case ConnStatus.UnpairedAndBroadcasting:
                    /* Use the settings button as a cancel button in this state */
                    self.settingsButton.setTitle("Cancel", for: .normal)

                    self.connInfoLabel.text = "Broadcasting..."
                    self.connSpinner.isHidden = false
                    self.connSpinner.startAnimating()
                    self.pairButton.isHidden = true

                    /* Can't send gesture data when disconnected */
                    self.shouldRecognizeGestures(enabled: false)

                case ConnStatus.PairedAndConnected:
                    self.settingsButton.setTitle("Settings", for: .normal)

                    self.connInfoLabel.text = "Swipe or tap to start"
                    self.connSpinner.isHidden = true
                    self.connSpinner.stopAnimating()
                    self.pairButton.isHidden = true

                    self.shouldRecognizeGestures(enabled: true)

                case ConnStatus.PairedAndDisconnected:
                    self.settingsButton.setTitle("Settings", for: .normal)

                    self.connInfoLabel.text = "Disconnected, attempting to reconnect..."
                    self.connSpinner.isHidden = false
                    self.connSpinner.startAnimating()
                    self.pairButton.isHidden = true

                    /* Can't send gesture data when disconnected */
                    self.shouldRecognizeGestures(enabled: false)
            }

            /* Draw the connection status and the spinner */
            self.view.setNeedsDisplay()
        }
    }

    /**
     * @brief Run whenever the view's size changes. For us, this only occurs when the device is rotated
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        /* Re-draw the connection status */
        self.view.setNeedsDisplay()
    }
}

/**
 * @brief Delegate for preventing simultaneous recognition of complex gesture (i.e. pinch and pan)
 */
extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {

        /* Only allow simultaneous gestures when one of the gestures is singleTouch or doubleTouch */
        if (gestureRecognizer == self.singleTouchGestureRecognizer || gestureRecognizer == self.doubleTouchGestureRecognizer) {
            return true
        }
        return false
    }
}
