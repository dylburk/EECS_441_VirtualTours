//
//  ARViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/7/21.
//

import Foundation
import UIKit
import ARKit
import SceneKit
import MapKit
import ARCL
import CoreLocation


class ARViewController: UIViewController, CLLocationManagerDelegate{

    var arView: SceneLocationView!
    
    let locationManager = CLLocationManager()
    var landmarks: [Landmark]!
    var selectedLandmark: Landmark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SMS notification
        let store = NearbyStore()
        store.getNearby(refresh: {}, completion: {})
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        landmarks = []
        
        arView = SceneLocationView()
        view.addSubview(arView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200.0))
        navigationBar.barTintColor = UIColor.systemBackground
        self.view.addSubview(navigationBar);
        let navigationItem = UINavigationItem(title: "VT")
        navigationBar.setItems([navigationItem], animated: false)
        
        // Run the view's AR session
        print("running view")
        arView.run()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        // draw the AR scene
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arView.pause()
    }
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      arView.frame = view.bounds
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last!
            print("My Location: ", location.coordinate.latitude, location.coordinate.longitude)
            getLandmarks(location:location)
                

            if location.horizontalAccuracy < 100 {
              manager.stopUpdatingLocation()
            }
        }
    }
    
    func getLandmarks(location: CLLocation){
        print("Finding landmarks")
        
        let loader = LandmarkLoader()
        loader.loadLandmarks(location: location){ landmarkDict, error in
        
            
            if let dict = landmarkDict {
                guard let result = dict.object(forKey: "landmarks") as? [NSDictionary]  else { return }
                for item in result {
                    
                    let latitude = item.value(forKeyPath: "location.lat") as! CLLocationDegrees
                    let longitude = item.value(forKeyPath: "location.lng") as! CLLocationDegrees
                    let title = item.object(forKey: "name") as! String
                    print(title)
                    
                    let landmark = Landmark(latitude: latitude,
                                       longitude: longitude,
                                       title: title)
                    self.landmarks.append(landmark)
                    self.addLandmarkToARScene(landmark)
                }
            }
        }
    }
    
    func addLandmarkToARScene(_ landmark: Landmark){
        let location = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
        let name = landmark.title
        DispatchQueue.main.async {
            let labeledView = UIView.prettyLabeledView(text: name, backgroundColor: UIColor.black.withAlphaComponent(0.75))

            let annotationNode = LocationAnnotationNode(location: location, view: labeledView)
            annotationNode.annotationHeightAdjustmentFactor = 7.0
            annotationNode.continuallyUpdatePositionAndScale = true
            annotationNode.continuallyAdjustNodePositionWhenWithinRange = true
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = SCNBillboardAxis.Y
            annotationNode.constraints = [billboardConstraint]
        
            // add node to AR scene
            self.arView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        }
    }
    

}

extension UIView {
    /// Create a colored view with label, border, and rounded corners.
    class func prettyLabeledView(text: String,
                                 backgroundColor: UIColor = .systemBackground,
                                 borderColor: UIColor = .clear) -> UIView {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        label.attributedText = attributedString
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        let cframe = CGRect(x: 0, y: 0, width: label.frame.width + 20, height: label.frame.height + 10)
        let cview = UIView(frame: cframe)
        cview.translatesAutoresizingMaskIntoConstraints = false
        cview.layer.cornerRadius = 10
        cview.layer.backgroundColor = backgroundColor.cgColor
        cview.layer.borderColor = borderColor.cgColor
        cview.layer.borderWidth = 1
        cview.addSubview(label)
        label.center = cview.center

        return cview
    }

}

