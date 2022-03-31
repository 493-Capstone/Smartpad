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
    
    /* Passed on initialization */
    var connStatus: ConnStatus!

    override func viewDidLoad() {
        super.viewDidLoad()

        if (connStatus == ConnStatus.Unpaired) {
            /* Show settings for unpaired device */
            setUIToUnpairedStatus()
        }
        else {
            /* Show settings for paired device */
            setUIToPairedStatus()
        }
    }
    
    private func setUIToUnpairedStatus(){
        pairedInfoLabel.text = "Device is not paired."
        unpairButton.isHidden = true
        
        changeNameLabel.text = "Change name:"
        changeNameField.isHidden = false
        // TODO: set changeNameField text to the current device identifier
        changeNameField.text = "TODO: Fill me in with the current id!"
    }
    
    private func setUIToPairedStatus(){
        let connData = ConnectionData()
        let pairedDeviceName = connData.getSelectedPeer()
        pairedInfoLabel.text = "Device is paired: \(pairedDeviceName)"
        unpairButton.isHidden = false

        changeNameLabel.text = "Changing name is not available when paired."
        changeNameField.isHidden = true
    }
    
    @IBAction func unpairDevice(_ sender: UIButton) {
        ConnectionManagerAccess.connectionManager.unpairDevice()
        setUIToUnpairedStatus()
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
