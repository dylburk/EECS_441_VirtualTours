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
    var facing: String = "unknown"
    
    init(latitude: Double = 0.0, longitude: Double = 0.0, location: String = "", facing: String = "unknown"){
        self.latitude = latitude;
        self.longitude = longitude;
        self.location = location;
        self.facing = facing
    }
    
    private lazy var locmanager = CLLocationManager()
    
    override init(){
        super.init()
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest
        locmanager.requestAlwaysAuthorization()
        
        locmanager.startUpdatingLocation()
        locmanager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            // Reverse geocode to get user's city name
            GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { response , _ in
                if let address = response?.firstResult(), let lines = address.lines {
                    // get city name from the first address returned
                    self.location = lines[0].components(separatedBy: ", ")[1]
                }
            }
            
            print(latitude)
            print(longitude)
            locmanager.stopUpdatingLocation()
        }
        
    }
}
