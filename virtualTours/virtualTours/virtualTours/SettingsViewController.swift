//
//  SettingsViewController.swift
//  virtualTours
//
//  Created by Ved Ameresh on 4/7/21.
//

import Foundation
import UIKit
import SceneKit
import CoreLocation

class SettingsViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var sendNotifInput: UISwitch!
    let phoneNumberKey = "phoneNumber"
    let sendNotifKey = "sendNotif"
    
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        let defaults = UserDefaults.standard
        if let textFieldValue = defaults.string(forKey: phoneNumberKey) {
            phoneNumberInput.text = textFieldValue
        }
        let sendNotifValue = defaults.bool(forKey: sendNotifKey)
        sendNotifInput.setOn(sendNotifValue, animated: false)
    
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        print("settings saved")
        let defaults = UserDefaults.standard
        defaults.setValue(phoneNumberInput.text, forKey: phoneNumberKey)
        defaults.setValue(sendNotifInput.isOn, forKey: sendNotifKey)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
}
