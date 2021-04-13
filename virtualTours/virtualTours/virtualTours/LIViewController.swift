//
//  LIViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/23/21.
//

import Foundation
import UIKit
import GoogleMaps

func formatTypeString(types: [String]) -> String {
    if types.isEmpty {
        return "NULL"
    }
    
    var type = types[0]
    
    type = type.replacingOccurrences(of: "_", with: " ")
    return type.capitalized
}

class LIViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var mMap: GMSMapView!
    
    var id : String = ""
    
    let landmarkInfoLoader = LandmarkInfoLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mMap.delegate = self
        
        if id != "" {
            landmarkInfoLoader.loadLandmark(id: id) { info, error in
                self.populateView(landmarkInfo: info, error: error)
            }
        }
        
    }
    
    func setID(id: String) {
        self.id = id
    }
    
    func populateView(landmarkInfo : LandmarkInfo?, error : NSError?) {
        if (error != nil) {
            print("Something went wrong getting landmarks")
            return
        }
        
        guard let info = landmarkInfo else {
            print("Something went wrong getting landmarks")
            return
        }
        
        DispatchQueue.main.async {
            self.titleLabel.text = info.name
            self.descLabel.text = info.description
            self.typeLabel.text = formatTypeString(types: info.types)
            self.addressLabel.text = "Address: " + info.address
            /*var openString = info.open
             if (openString == "No hours available"){
                
            } else {
                openString = info.open ? "Open" : "Closed"
            }*/
            let openString = info.open ? "Open" : "Closed"
            let hoursString = NSMutableAttributedString(string: "Hours: " + openString,
                                                        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                     NSAttributedString.Key.foregroundColor: UIColor.black])
            if info.open {
                hoursString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: NSRange(location:7,length:4))
            } else {
                hoursString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: NSRange(location:7,length:6))
            }
            
            self.hoursLabel.attributedText = hoursString
            
            let ratingString = (info.rating == -1) ? "No Rating" : String(info.rating)
            
            self.ratingLabel.text = "Rating: " + ratingString
            self.websiteLabel.text = "Website: " + info.website
            
            
            // MAP CONFIG
            let landmarkMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude))
            landmarkMarker.map = self.mMap
            landmarkMarker.userData = info
            
            self.mMap.camera = GMSCameraPosition.camera(withTarget: landmarkMarker.position, zoom: 17.5)
        }
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
                    //UILabel(frame: CGRect.init(x: timestamp.frame.origin.x, y: timestamp.frame.origin.y + timestamp.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
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
                
                // let latitudeText:String = "\(landmark.latitude)"
                // let longitudeText:String = "\(landmark.longitude)"
                
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
                print(info!.open)
                openLabel.font = UIFont.systemFont(ofSize: 16)
                // let openString = "Open Now"
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
                //let distanceInMiles = (distanceInMeters/1609.344)
                //print("Distance: " + distanceText)

                let distanceLabel = UILabel(frame: CGRect.init(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height + 100, width: infoView.frame.size.width - 16, height: 15))
                distanceLabel.text = String(format: "Distance: %.01f m", distanceInMeters)
                distanceLabel.font = UIFont.systemFont(ofSize: 16)
                
                distanceLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                distanceLabel.numberOfLines = 2
                
                distanceLabel.textColor = .black
                // distanceLabel.highlight(searchedText: distanceInMiles)
                infoView.addSubview(distanceLabel)
            }
            
        }
        
        //sleep(1)
        semaphore.wait()
        return infoView
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
