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

    @IBOutlet var settingsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        /* Setup the connection manager */
        connectionManager = ConnectionManager()
        
        /* Setup the haptic engine */
        hapticManager = HapticManager()
    }


    func getDeltaTranslation(sender: UIPanGestureRecognizer) -> CGPoint {
        let translation: CGPoint = sender.translation(in: sender.view)
        var deltaTranslation = translation
        
        if sender.state != UIGestureRecognizer.State.began {
            deltaTranslation = CGPoint(x: translation.x - previousCoordinates.x, y: translation.y - previousCoordinates.y)
        }
        previousCoordinates = translation
        return deltaTranslation
    }

    
    @IBAction func panMotionSimple(_ sender: UIPanGestureRecognizer) {
        let deltaTranslation = getDeltaTranslation(sender: sender)
        
        hapticManager?.playSlice();

        connectionManager?.sendMotion(gesture: "\(deltaTranslation.x) \(deltaTranslation.y)")    }
    
    @IBAction func settingsButtonPressed() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

