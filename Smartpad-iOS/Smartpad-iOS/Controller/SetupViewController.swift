//
//  SetupViewController.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

/**
 * View controller for the setup page.
 *
 * Required for functional requirement FR1 (allow settings a device unique identifier)
 */

import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var idField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "setupView"
        let connData = ConnectionData()
        // set the device uuid upon initial setup
        if (connData.getCurrentDeviceUUID() == ""){
            connData.setCurrentDeviceUUID(uuid: UUID().uuidString)
        }
        idField.delegate = self
    }

    // TODO: Ali can you pls explain this
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " '")).inverted // append white space and apostrophe
        let components = string.components(separatedBy: allowedCharacters)
        let filtered = components.joined(separator: "")

        return string == filtered
    }

    // Is this used??
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.text != ""
    }

    /**
     * @brief Called when the view is shown. If the device name is setup, we hand control over to the main view controller
     */
    override func viewDidAppear(_ animated: Bool) {
        if ConnectionData().getDeviceName() != "" {
            goToMainView()
        }
    }

    /**
     * @brief Called when the name field is filled. If the device name is non-empty, we hand control over to the main view controller
     */
    @IBAction func didFillText() {
        if let unwrapped = idField.text {
            /* Set device name */
            ConnectionData().setDeviceName(name: unwrapped)

            goToMainView()
        }
        else {
            /* Text field was empty, don't allow empty identifiers */
        }
    }

    /**
     * @brief Hand control over to the main view controller (shows hte main view)
     */
    func goToMainView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "main") as! MainViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    /* Only allow viewing in portrait mode */
    // https://developer.apple.com/forums/thread/62008
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return UIInterfaceOrientationMask.portrait
    }

    /* Don't allow rotating */
    // https://developer.apple.com/forums/thread/62008
    override var shouldAutorotate: Bool {
        return false
    }
}
