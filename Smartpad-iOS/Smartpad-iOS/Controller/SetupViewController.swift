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
    
    @IBAction func didFillText() {
        if let unwrapped = idField.text {
            /* TODO: We should save the identifier somewhere rather than just printing it */
            print(unwrapped)

            let vc = storyboard?.instantiateViewController(withIdentifier: "main") as! MainViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        else {
            /* Text field was empty, don't allow empty identifiers */
        }
    }
}
