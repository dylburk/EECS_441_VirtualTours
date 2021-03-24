//
//  ARViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/7/21.
//

import Foundation
import UIKit
import SceneKit


class NotificationViewController: UIViewController {


    @IBOutlet weak var myPhoneNumber: UITextField!
    let phoneNumberKey = "phoneNumber"

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let textFieldValue = defaults.string(forKey: phoneNumberKey) {
                    myPhoneNumber.text = textFieldValue
                }
    }
    
    @IBAction func myPhoneNumberButton(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.setValue(myPhoneNumber.text, forKey: phoneNumberKey)
        self.getNearbySMS()
    }
    
    func getNearbySMS() {
        let store = NearbyStore()
        store.getNearby(refresh: {}, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    

}
