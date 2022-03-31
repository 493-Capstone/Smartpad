//
//  SettingsViewController.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var pairedInfoLabel: UILabel!
    @IBOutlet var changeNameLabel: UILabel!
    @IBOutlet var changeNameField: UITextField!
    @IBOutlet var unpairButton: UIButton!

    private var connectionManager: ConnectionManager?
    
    /* Passed on initialization */
    var connStatus: ConnStatus!

    override func viewDidLoad() {
        super.viewDidLoad()

        connectionManager = ConnectionManagerAccess.connectionManager

        updateConnUI()
    }

    /**
     * @brief Update the portions of the UI that are dependent on whether we are paired or not
     */
    private func updateConnUI() {
        let connStatus = connectionManager?.getConnStatus()
        if (connStatus == ConnStatus.Unpaired) {
            pairedInfoLabel.text = "Device is not paired."
            unpairButton.isHidden = true

            changeNameLabel.text = "Change name:"
            changeNameField.isHidden = false
            // TODO: set changeNameField text to the current device identifier
            changeNameField.text = "TODO: Fill me in with the current id!"
        }
        else {
            let connData = ConnectionData()
            let pairedDeviceName = connData.getSelectedPeer()
            pairedInfoLabel.text = "Device is paired: \(pairedDeviceName)"
            unpairButton.isHidden = false

            changeNameLabel.text = "Changing name is not available when paired."
            changeNameField.isHidden = true
        }
    }
    
    @IBAction func unpairDevice(_ sender: UIButton) {
        connectionManager?.unpairDevice()
        updateConnUI()
    }
    
    @IBAction func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    /**
     * @brief Callback for when the "change name" field is modified
     */
    @IBAction func nameChanged() {
        if let unwrapped = changeNameField.text {
            print("The new identifier is: ", unwrapped)
        }
        else {
            print("Identifier cannot be empty!")
        }
    }
}
