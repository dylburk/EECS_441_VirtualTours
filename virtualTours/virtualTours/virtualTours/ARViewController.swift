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


class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, LNTouchDelegate {

    @IBOutlet weak var contentView: UIView!
    
    var arView: SceneLocationView!
    let locationManager = CLLocationManager()
    var lastLandmarkUpdate = CLLocation()
    var lastLocation = CLLocation()
    
    let locationUpdateFilter = 5.0
    let landmarkUpdateFilter = 30.0
    
    let arRadius = 30.0
    
    let eastMultiplier = 75000.0
    let northMultiplier = 95000.0
    
    public var locationEstimateMethod = LocationEstimateMethod.mostRelevantEstimate
    public var arTrackingType = SceneLocationView.ARTrackingType.orientationTracking
    public var scalingScheme = ScalingScheme.normal
    public var continuallyAdjustNodePositionWhenWithinRange = true
    public var continuallyUpdatePositionAndScale = true
    public var annotationHeightAdjustmentFactor = 1.0
    public var colorIndex = 0
    public var supported_types = ["cafe", "establishment", "restaurant", "school"]
    
    var landmarks : [Landmark]! = []
    
    
    let colors = [UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange, UIColor.systemPurple, UIColor.systemYellow,
                  UIColor.systemRed]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        // SMS notification
        let store = NearbyStore()
        store.getNearby(refresh: {}, completion: {})*/
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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
        newARView.locationNodeTouchDelegate = self
        newARView.locationEstimateMethod = locationEstimateMethod

        newARView.debugOptions = [.showWorldOrigin]
        newARView.showAxesNode = false
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
            print("locationManager refreshed")
            if(lastLandmarkUpdate.distance(from: locations.last!) > landmarkUpdateFilter || landmarks.isEmpty) {
                lastLandmarkUpdate = locations.last!
                print("retrieving from backend")
                arView.removeAllNodes()
                self.updateLandmarks()
            }
            else if (lastLocation.distance(from: locations.last!) > locationUpdateFilter) {
                lastLocation = locations.last!
                print("updating location")
                arView.removeAllNodes()
                self.addLandmarks(lastLocation)
            }

        }
    }
    
    func setNode(_ node: LocationNode) {
        if let annoNode = node as? LocationAnnotationNode {
            //print("refactoring height")
            annoNode.annotationHeightAdjustmentFactor = annotationHeightAdjustmentFactor
        }
        node.scalingScheme = scalingScheme
        node.continuallyAdjustNodePositionWhenWithinRange = continuallyAdjustNodePositionWhenWithinRange
        node.continuallyUpdatePositionAndScale = continuallyUpdatePositionAndScale
    }
    
    func updateLandmarks() {
        guard let currentLocation = arView?.sceneLocationManager.currentLocation else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateLandmarks()
                //print("getting landmarks")
            }
            return
        }
        
        
        self.getLandmarks(currentLocation: currentLocation) { error in
            if (error != nil) {
                print(error!)
                return
            }
            self.colorIndex += 1
            self.addLandmarks(currentLocation)
            //self.addDynamicNodes(currentLocation)
        }
    }
    
    
    func addLandmarks(_ currentLocation: CLLocation){
        //print("Adding landmarks")
        if landmarks.isEmpty {
            return
        }
        
        //print("landmarks: ", landmarks.count)
        
        for landmark in landmarks {
            //print(landmark.title)
            addLandmarkToARScene(currentLocation: currentLocation, landmark: landmark)
        }

    }
    
    func getLandmarks(currentLocation: CLLocation, handler: @escaping (NSError?) -> Void) {
        let loader = LandmarkLoader()
        
        loader.loadLandmarks(location: currentLocation) { landmarkDict, error in
            if let dict = landmarkDict {
                print(dict)
                guard let result = dict.object(forKey: "landmarks") as? [NSDictionary]  else { return }
                self.landmarks = []
                for item in result {

                   /* let latitude = item.value(forKeyPath: "location.lat") as! CLLocationDegrees
                    let longitude = item.value(forKeyPath: "location.lng") as! CLLocationDegrees*/
                    let title = item.object(forKey: "name") as! String
                    let id = item.value(forKey: "id") as! String
                    let latitude = 42.195942
                    let longitude = -85.713417
                    //let title = "Gamer Zone"
                    let types = item.object(forKey: "types") as! [Any]

                    let landmark = Landmark(latitude: latitude,
                                       longitude: longitude,
                                       title: title,
                                       id: id,
                                       types: types)
                    print(landmark)
                    self.landmarks.append(landmark)
                    break
                }
                //print("LANDMARKS:")
                print(self.landmarks!)
                handler(nil)
            }
        }
    }
    
    func addLandmarkToARScene(currentLocation: CLLocation, landmark: Landmark){
        
        
        //let location = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
        let northOffset = (landmark.latitude - currentLocation.coordinate.latitude) * (northMultiplier)
        let eastOffset = (landmark.longitude - currentLocation.coordinate.longitude) * (eastMultiplier)
        
        
        
        let location = currentLocation.translatedLocation(with: LocationTranslation(latitudeTranslation: Double(northOffset), longitudeTranslation: Double(eastOffset), altitudeTranslation: 0))
        let name = landmark.title
        let color = colors[colorIndex % colors.count]
        var type = String()
        for (_, supported_type) in landmark.types.enumerated() {
            if (self.supported_types.contains(supported_type as! String)) {
                type = supported_type as! String
            }
        }
        type = "point_of_interest"
        
        let distance = currentLocation.distance(from: location)
        if(distance > arRadius){
            print("Too far to \(landmark.title): (\(distance)m")
            return
        }
        print("Close enough to \(landmark.title): (\(distance)m")
        
        
        DispatchQueue.main.async {
            let labeledView = UIView.prettyLabeledView(text: name, backgroundColor: color.withAlphaComponent(0.75), type: type)

            let laNode = LocationAnnotationNode(location: location, view: labeledView)
            laNode.tag = landmark.id
            laNode.annotationNode.tag = landmark.id
            self.setNode(laNode)
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = SCNBillboardAxis.Y
            laNode.constraints = [billboardConstraint]
        
            // add node to AR scene
            self.arView.addLocationNodeWithConfirmedLocation(locationNode: laNode)
        }
    }
    @objc func annotationNodeTouched(node: AnnotationNode) {
        // Need to abstract the functionality of this to a seperate class
        //print("Annotation Tap")
        //print(node.tag)
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "LandmarkInfo") as! LIViewController
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.setID(id: node.tag)
        present(popupVC, animated: true, completion: nil)
    }
    
    @objc func locationNodeTouched(node: LocationNode) {
        //print("Location Tap")
        //print(node.tag!)
    }

}
extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}
extension UIView {
    /// Create a colored view with label, border, and rounded corners.
    class func prettyLabeledView(text: String,
                                 backgroundColor: UIColor = .systemBackground,
                                 borderColor: UIColor = .clear,
                                 type: String) -> UIView {
        
        let font = UIFont.preferredFont(forTextStyle: .title2).bold()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 30))
        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        
        label.textColor = .black
        label.numberOfLines = 0
        label.attributedText = attributedString
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        label.font = label.font.withSize(8)

        
        let cframe = CGRect(x: 0, y: 0, width: label.frame.width + 45, height: label.frame.height + 10)
        
        let cview = UIView(frame: cframe)
        cview.translatesAutoresizingMaskIntoConstraints = false
        cview.layer.cornerRadius = 10
        cview.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
        cview.layer.borderColor = UIColor.black.cgColor
        cview.layer.borderWidth = 1
        
        let Image = UIImage(named: type)
        let Imageframe = CGRect(x: 130, y: cview.frame.height - 27, width: 15, height: 15)
        let myImageView = UIImageView()
        myImageView.image = Image
        myImageView.frame = Imageframe
        
        cview.addSubview(label)
        cview.addSubview(myImageView)
        
        label.center = cview.center
        return cview
    }

}
extension AnnotationNode {
    struct Holder {
        static var tag = [String:String]()
    }
    
    var tag: String {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return Holder.tag[tmpAddress] ?? ""
        }
        set (newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            Holder.tag[tmpAddress] = newValue
        }
    }
}
