//
//  MapsVC.swift
//  virtualTours
//
//  Created by Ryan Magyar on 4/9/21.
//

import Foundation
import UIKit
import GoogleMaps

class MapsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mMap: GMSMapView!
    var landmarks: [Landmark]? = nil
    private lazy var locmanager = CLLocationManager()
    
    let landmarkInfoLoader = LandmarkInfoLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set self as the delegate for GMSMapView's infoWindow events
        mMap.delegate = self
        // put mylocation marker down; Google automatically asks for location permission
        mMap.isMyLocationEnabled = true
        // enable the location bull's eye button
        mMap.settings.myLocationButton = true
        
        var landmarkMarker: GMSMarker!
        
        // set self as the delegate for CLLocationManager's events
        // and set up the location manager.
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest
        
        // obtain user's current location so that we can
        // zoom the map to the current location
        locmanager.startUpdatingLocation()
        
        for landmark in landmarks! {
            landmarkMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude))
            landmarkMarker.map = mMap
            landmarkMarker.userData = landmark
        }
            
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = mMap.myLocation else {
            return
        }
        locmanager.stopUpdatingLocation()
        
        // Zoom in to the user's current location
        mMap.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17.5)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            guard let landmark = marker.userData as? Landmark else {
                return nil
            }
            let id = landmark.id
            let infoView = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 150))
            let semaphore = DispatchSemaphore(value: 0)
            
            landmarkInfoLoader.loadLandmark(id: id) { info, error in
                if (error != nil){
                    print("ERROR")
                }
                semaphore.signal()
                DispatchQueue.main.async {
                    infoView.backgroundColor = UIColor.white
                    infoView.layer.cornerRadius = 6
                    
                    
                    let nameLabel = UILabel(frame: CGRect.init(x: 10, y: 10, width: infoView.frame.size.width - 16, height: 18))

                    nameLabel.text = info?.name
                    nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                    nameLabel.textColor = .black
                    infoView.addSubview(nameLabel)
                    
                    let websiteLabel = UILabel(frame: CGRect.init(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height + 75, width: infoView.frame.size.width - 16, height: 20))
                    websiteLabel.text = info?.website
                    websiteLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                    websiteLabel.textColor = .systemBlue
                    infoView.addSubview(websiteLabel)
                    
                    let addressLabel = UILabel(frame: CGRect.init(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height + 5, width: infoView.frame.size.width - 20, height: 40))
                    addressLabel.text = info?.address
                    addressLabel.textColor = .darkGray
                    addressLabel.font = UIFont.systemFont(ofSize: 16)
                    addressLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                    addressLabel.numberOfLines = 2
                    infoView.addSubview(addressLabel)
                    
                    let ratingLabel = UILabel(frame: CGRect.init(x: nameLabel.frame.origin.x, y: addressLabel.frame.origin.y + addressLabel.frame.size.height + 5, width: infoView.frame.size.width - 200, height: 20))
                    let ratingNum:String = "\(info!.rating)"
                    if (info?.rating == -1){
                        ratingLabel.text = "No Rating"
                    } else {
                        ratingLabel.text = "Rating: " + ratingNum
                    }
                    
                    
                    ratingLabel.font = UIFont.systemFont(ofSize: 16)
                    ratingLabel.textColor = .black
                    infoView.addSubview(ratingLabel)
                    
                    let openLabel = UILabel(frame: CGRect.init(x: nameLabel.frame.origin.x + 125, y: addressLabel.frame.origin.y + addressLabel.frame.size.height + 5, width: infoView.frame.size.width - 20, height: 20))
                    
                    
                    let hoursString = info!.hours
                    
                    let openString = info!.open ? "Open Now" : "Closed Now"

                    openLabel.font = UIFont.systemFont(ofSize: 16)

                    if (openString == "Open Now"){
                        openLabel.textColor = .systemGreen
                    } else {
                        openLabel.textColor = .red
                    }
                    if (hoursString == "No hours available"){
                        openLabel.text = hoursString
                    } else {
                        openLabel.text = openString
                    }
                    
                    infoView.addSubview(openLabel)
                    
                    let landmarkLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
                    let distanceInMeters = (self.mMap.myLocation?.distance(from: landmarkLocation))!

                    let distanceLabel = UILabel(frame: CGRect.init(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height + 100, width: infoView.frame.size.width - 16, height: 15))
                    distanceLabel.text = String(format: "Distance: %.01f m", distanceInMeters)
                    distanceLabel.font = UIFont.systemFont(ofSize: 16)
                    
                    distanceLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                    distanceLabel.numberOfLines = 2
                    
                    distanceLabel.textColor = .black

                    infoView.addSubview(distanceLabel)
                }
                
            }
            
            semaphore.wait()
            return infoView
        }

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
