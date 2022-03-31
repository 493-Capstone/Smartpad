//
//  SetupViewController.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

import UIKit

class SetupViewController: UIViewController {
    
    @IBOutlet var idField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        let connData = ConnectionData()
        if connData.getDeviceName() != "" {
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
}
