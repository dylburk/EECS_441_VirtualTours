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


class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate{

    
    @IBOutlet weak var contentView: UIView!
    
    var arView: SceneLocationView!
    let locationManager = CLLocationManager()
    var lastLocation = CLLocation()
    
    
    
    public var locationEstimateMethod = LocationEstimateMethod.mostRelevantEstimate
    public var arTrackingType = SceneLocationView.ARTrackingType.orientationTracking
    public var scalingScheme = ScalingScheme.normal
    public var continuallyAdjustNodePositionWhenWithinRange = true
    public var continuallyUpdatePositionAndScale = true
    public var annotationHeightAdjustmentFactor = 1.1
    public var colorIndex = 0
    
    var landmarks: [Landmark]!
    
    
    let colors = [UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange, UIColor.systemPurple, UIColor.systemYellow,
                  UIColor.systemRed]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        // SMS notification
        let store = NearbyStore()
        store.getNearby(refresh: {}, completion: {})*/
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        landmarks = []
        
        arView = SceneLocationView()
        view.addSubview(arView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func refactorScene(){
        arView?.removeFromSuperview()
        let newARView = SceneLocationView.init(trackingType: arTrackingType, frame: contentView.frame, options: nil)
        newARView.translatesAutoresizingMaskIntoConstraints = false
        newARView.arViewDelegate = self
        newARView.locationEstimateMethod = locationEstimateMethod

        newARView.debugOptions = [.showWorldOrigin]
        newARView.showAxesNode = false // don't need ARCL's axesNode because we're showing SceneKit's
        newARView.autoenablesDefaultLighting = true
        contentView.addSubview(newARView)
        arView = newARView
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refactorScene()
        arView?.run()
        // draw the AR scene
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        arView?.removeAllNodes()
        arView?.pause()
        super.viewWillDisappear(animated)
        
        // Pause the view's session
    }
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      arView?.frame = view.bounds
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            lastLocation = locations.last!
            print("My Location: ", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
            landmarks = []
            arView?.removeAllNodes()
            getLandmarks()
            addLandmarks()
            print(lastLocation.distance(from: locations.last!))

        }
    }
    
    func setNode(_ node: LocationNode) {
        if let annoNode = node as? LocationAnnotationNode {
            annoNode.annotationHeightAdjustmentFactor = annotationHeightAdjustmentFactor
        }
        node.scalingScheme = scalingScheme
        node.continuallyAdjustNodePositionWhenWithinRange = continuallyAdjustNodePositionWhenWithinRange
        node.continuallyUpdatePositionAndScale = continuallyUpdatePositionAndScale
    }
    
    
    func addLandmarks(){
        
        if landmarks.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.getLandmarks()
                self?.addLandmarks()
            }
        }
        
        
        print("landmarks: ", landmarks.count)
        
        for landmark in landmarks{
            print(landmark.title)
            addLandmarkToARScene(landmark)
        }

    }
    
    func getLandmarks(){
        let loader = LandmarkLoader()
        guard let currentLocation = arView?.sceneLocationManager.currentLocation else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.getLandmarks()
                print("getting landmarks")
            }
            return
        }
        loader.loadLandmarks(location: currentLocation){ landmarkDict, error in
            if let dict = landmarkDict {
                guard let result = dict.object(forKey: "landmarks") as? [NSDictionary]  else { return }
                for item in result {

                    let latitude = item.value(forKeyPath: "location.lat") as! CLLocationDegrees
                    let longitude = item.value(forKeyPath: "location.lng") as! CLLocationDegrees
                    let title = item.object(forKey: "name") as! String
                    

                    let landmark = Landmark(latitude: latitude,
                                       longitude: longitude,
                                       title: title)
                    self.landmarks.append(landmark)
                }
            }
        }
    }
    
    
//    func getLandmarks(location: CLLocation){
//        print("Finding landmarks")
//
//        let loader = LandmarkLoader()
//        loader.loadLandmarks(location: location){ landmarkDict, error in
//
//
//            if let dict = landmarkDict {
//                guard let result = dict.object(forKey: "landmarks") as? [NSDictionary]  else { return }
//                for item in result {
//
//                    let latitude = item.value(forKeyPath: "location.lat") as! CLLocationDegrees
//                    let longitude = item.value(forKeyPath: "location.lng") as! CLLocationDegrees
//                    let title = item.object(forKey: "name") as! String
//                    print(title)
//
//                    let landmark = Landmark(latitude: latitude,
//                                       longitude: longitude,
//                                       title: title)
//                    //self.landmarks.append(landmark)
//                    self.addLandmarkToARScene(landmark)
//                }
//            }
//        }
//    }
    
    func addLandmarkToARScene(_ landmark: Landmark){
        let location = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
        let name = landmark.title
        let color = colors[colorIndex % colors.count]
        colorIndex += 1
        
        
        DispatchQueue.main.async {
            let labeledView = UIView.prettyLabeledView(text: name, backgroundColor: color.withAlphaComponent(0.75))

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

