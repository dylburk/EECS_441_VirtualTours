//
//  ARViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/7/21.
//

import Foundation
import UIKit
import SceneKit
import CoreLocation


class NotificationViewController: UIViewController, CLLocationManagerDelegate {


    @IBOutlet weak var myPhoneNumber: UITextField!
    let phoneNumberKey = "phoneNumber"
    let locationManager = CLLocationManager()
    var lastLocation = CLLocation()
    let locationUpdateFilter = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startMonitoringSignificantLocationChanges()
        let defaults = UserDefaults.standard
        if let textFieldValue = defaults.string(forKey: phoneNumberKey) {
            myPhoneNumber.text = textFieldValue
        }
    }
    
    @IBAction func myPhoneNumberButton(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.setValue(myPhoneNumber.text, forKey: phoneNumberKey)
    }
    
    func getNearbySMS(currentLocation: CLLocation) {
        let store = NearbyStore()
        store.getNearby(currentLocation: currentLocation, refresh: {}, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if locations.count > 0 {
                if (lastLocation.distance(from: locations.last!) > locationUpdateFilter) {
                    print("updating location")
                    lastLocation = locations.last!
                    self.getNearbySMS(currentLocation: lastLocation)
                }

            }
        }
    
    

}
