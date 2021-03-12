//
//  ViewController.swift
//  virtualTours
//
//  Created by Dylan Burkett on 3/5/21.
//

import UIKit
import GooglePlaces


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    private var placesClient: GMSPlacesClient!

    private lazy var locmanager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locmanager.requestAlwaysAuthorization()

        placesClient = GMSPlacesClient.shared()
        
    }

    @IBAction func getCurrentPlace(_ sender: UIButton) {
        let placeFields: GMSPlaceField = [.name, .formattedAddress]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "")")
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                for likelihood in placeLikelihoods {
                  let place = likelihood.place
                  print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
                  print("Current PlaceID \(String(describing: place.placeID))")
                }
            }


            guard let place = placeLikelihoods?.first?.place else {
                strongSelf.namesLabel.text = "No current place"
                strongSelf.addressLabel.text = ""
                return
            }

            strongSelf.namesLabel.text = place.name
            strongSelf.addressLabel.text = place.formattedAddress
        }
    }
    
}

