//
//  SettingsViewController.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var backButton: UIButton!

    /* Passed on initialization */
    var connStatus: ConnStatus!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
