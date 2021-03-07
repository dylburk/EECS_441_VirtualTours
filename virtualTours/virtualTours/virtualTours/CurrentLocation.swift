//
//  CurrentLocation.swift
//  virtualTours
//
//  Created by Nicholas Keller on 3/7/21.
//

import Foundation
import GoogleMaps

class CurrentLocation: NSObject, CLLocationManagerDelegate {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var location: String = ""
    
    init(latitude: Double = 0.0, longitude: Double = 0.0, location: String = ""){
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
    }
    
    private lazy var locmanager = CLLocationManager()
    
    override init(){
        super.init()
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest
        locmanager.requestAlwaysAuthorization()
        locmanager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
        }
        locmanager.stopUpdatingLocation()
        }
}
