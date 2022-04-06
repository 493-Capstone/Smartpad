//
//  SettingsViewController.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

/**
 * Settings view controller. Controls the settings application view.
 *
 * Required for functional requirements FR1 (changing device identifier) and FR3 (forgetting device)
 * Required for user interface requirement UIR-2 (unpairing UI).
 */

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
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
        changeNameField.delegate = self
    }

    // TODO: Ali what does this do
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " '")).inverted // append white space and apostrophe
        let components = string.components(separatedBy: allowedCharacters)
        let filtered = components.joined(separator: "")

        return string == filtered
    }

    // TODO: Ali what does this do
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let unwrapped = changeNameField.text else { return true}

        if (unwrapped != "") {
            ConnectionData().setDeviceName(name: unwrapped)
            return true
        }
        else {
            /* User tried to enter an empty name */
            let connData = ConnectionData()
            let emptyNameAlert = UIAlertController(title: "Smartpad", message: "Device name cannot be empty!", preferredStyle: .alert)
            emptyNameAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in}))
            present(emptyNameAlert, animated: true)
            // set it back to original name
            textField.text = connData.getDeviceName()
            return true
        }
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
            let pairedDeviceName = connData.getSelectedPeer(formatString: true)
            pairedInfoLabel.text = "Device is paired: \(pairedDeviceName)"
            unpairButton.isHidden = false

            changeNameLabel.text = "Changing name is not available when paired."

            /* Disable and "grey out" the field */
            changeNameField.isEnabled = false
            changeNameField.textColor = .secondaryLabel
        }
    }

    /**
     * @brief Callback for when the unpair device button is pressed
     */
    @IBAction func unpairDevice(_ sender: UIButton) {
        connectionManager?.unpairDevice()
        updateConnUI()
    }

    /**
     * @brief Callback for when the back button is pressed
     */
    @IBAction func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
