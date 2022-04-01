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

        changeNameField.text = ConnectionData().getDeviceName()
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

            /* Enable the field and set the color to its default */
            changeNameField.isEnabled = true
            changeNameField.textColor = .label
        }
        else {
            let connData = ConnectionData()
            let pairedDeviceName = connData.getSelectedPeer()
            pairedInfoLabel.text = "Device is paired: \(pairedDeviceName)"
            unpairButton.isHidden = false

            changeNameLabel.text = "Changing name is not available when paired."

            /* Disable and "grey out" the field */
            changeNameField.isEnabled = false
            changeNameField.textColor = .secondaryLabel
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
        guard let unwrapped = changeNameField.text else { return }

        if (unwrapped != "") {
            ConnectionData().setDeviceName(name: unwrapped)
        }
        else {
            /* User tried to enter an empty name */
            let emptyNameAlert = UIAlertController(title: "Smartpad", message: "Device name cannot be empty!", preferredStyle: .alert)
            emptyNameAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in}))
            present(emptyNameAlert, animated: true)
        }
    }
}
