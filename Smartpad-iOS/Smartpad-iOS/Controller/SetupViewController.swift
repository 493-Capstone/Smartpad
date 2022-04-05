//
//  SetupViewController.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " '")).inverted // append white space and apostrophe
        let components = string.components(separatedBy: allowedCharacters)
        let filtered = components.joined(separator: "")
        
        if string == filtered {
            
            return true

        } else {
            
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" { // is empty
            return false
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ConnectionData().getDeviceName() != "" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "main") as! MainViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    @IBAction func didFillText() {
        if let unwrapped = idField.text {
            /* Set device name */
            ConnectionData().setDeviceName(name: unwrapped)

            /* Transition to main view controller */
            let vc = storyboard?.instantiateViewController(withIdentifier: "main") as! MainViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        else {
            /* Text field was empty, don't allow empty identifiers */
        }
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
