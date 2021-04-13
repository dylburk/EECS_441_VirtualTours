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
import SideMenu


class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, LNTouchDelegate, MenuControllerDelegate {
    
    
    private var sideMenu: SideMenuNavigationController?

    @IBOutlet weak var contentView: UIView!
    
    var arView: SceneLocationView!
    let locationManager = CLLocationManager()
    var lastLandmarkUpdate = CLLocation()
    var lastLocation = CLLocation()
    
    //let locationUpdateFilterSMS = 100.0
    
    let updateDeltaMeters = 10.0
    let locationUpdateFilter = 5.0
    let landmarkUpdateFilter = 30.0
    
    let arRadius = 30.0
    
    let eastMultiplier = 75000.0
    let northMultiplier = 95000.0
    
    public var locationEstimateMethod = LocationEstimateMethod.mostRelevantEstimate
    public var arTrackingType = SceneLocationView.ARTrackingType.worldTracking
    public var scalingScheme = ScalingScheme.normal
    public var continuallyAdjustNodePositionWhenWithinRange = true
    public var continuallyUpdatePositionAndScale = true
    public var annotationHeightAdjustmentFactor = 1.0
    public var colorIndex = 0
    public var supported_types = ["cafe", "establishment", "restaurant", "school", "bank"]
    
    var landmarks : [Landmark]! = []
    
    
    let colors = [UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange, UIColor.systemPurple, UIColor.systemYellow,
                  UIColor.systemRed]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menu = MenuController(with: ["Home", "Timeline", "Map", "Settings"])
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        //sideMenu?.presentationStyle.backgroundColor = UIColor.red
        sideMenu?.menuWidth = 200
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        // locationManager.distanceFilter = updateDeltaMeters // We think this might mess up the updates while walking, keep it commented out???
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        landmarks = []
        
        arView = SceneLocationView()
        view.addSubview(arView)
    }
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: {
            if named == "Home" {
                print("I am in the Home section")
            }
            else if named == "Timeline" {
                print(" I am in the Timeline section")
            }
            else if named == "Map" {
                print(" I am in the Map section")
            }
            else if named == "Settings" {
                print(" I am in the Settings section")
            }
        })
    }
    @IBAction func sidepanel(_ sender: Any) {
        present(sideMenu!, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sideMenu?.setNavigationBarHidden(true, animated: animated)
    }

    func refactorScene(){
        arView?.removeFromSuperview()
        let newARView = SceneLocationView.init(trackingType: arTrackingType, frame: contentView.frame, options: nil)
        newARView.translatesAutoresizingMaskIntoConstraints = false
        newARView.arViewDelegate = self
        newARView.locationNodeTouchDelegate = self
        newARView.sceneTrackingDelegate = nil
        newARView.locationEstimateMethod = locationEstimateMethod

        //newARView.debugOptions = [.showWorldOrigin, .showBoundingBoxes]
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
        //print("locationManager refreshed")
        if locations.count > 0 {
            //print("locationManager refreshed")
            if (lastLandmarkUpdate.distance(from: locations.last!) > landmarkUpdateFilter || landmarks.isEmpty) {
                lastLandmarkUpdate = locations.last!
                print("retrieving from backend")
                arView.removeAllNodes()
                self.getNearbySMS(currentLocation: locations.last!)
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

    func getNearbySMS(currentLocation: CLLocation) {
        DispatchQueue.main.async {
            let store = NearbyStore()
            store.getNearby(currentLocation: currentLocation, refresh: {}, completion: {})
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
            print("NEW THREAD")
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
            self.arView.removeAllNodes()
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
                //print(dict)
                guard let result = dict.object(forKey: "landmarks") as? [NSDictionary]  else { return }
                self.landmarks = []
                for item in result {


                    let latitude = item.value(forKeyPath: "location.lat") as! CLLocationDegrees
                    let longitude = item.value(forKeyPath: "location.lng") as! CLLocationDegrees
                    let title = item.object(forKey: "name") as! String
                    let id = item.value(forKey: "id") as! String
                    //let title = "Gamer Zone"
                    let types = item.object(forKey: "types") as! [Any]

                    let landmark = Landmark(latitude: latitude,
                                       longitude: longitude,
                                       title: title,
                                       id: id,
                                       types: types)
                    //print(landmark)
                    self.landmarks.append(landmark)
                    break
                }
                //print("LANDMARKS:")
                //print(self.landmarks!)
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
        type = "point_of_interest"
        for (_, supported_type) in landmark.types.enumerated() {
            if (self.supported_types.contains(supported_type as! String)) {
                type = supported_type as! String
            }
        }
        
        let distance = currentLocation.distance(from: location)
        if(distance > arRadius){
            print("Too far to \(landmark.title): (\(distance)m")
            //return
        }
        print("Close enough to \(landmark.title): (\(distance)m")
        
        
        DispatchQueue.main.async {
            let labeledView = UIView.prettyLabeledView(text: name, backgroundColor: color.withAlphaComponent(0.75), type: type)

            let laNode = LocationAnnotationNode(location: location, view: labeledView)
            laNode.tag = landmark.id
            laNode.annotationNode.tag = landmark.id
            self.setNode(laNode)
            
            //let nodePositionOnScreen = self.arView.projectPoint(nodeWorldPosition)
            
            //let hitPoint: CGPoint = CGPoint(x: Double(nodePositionOnScreen.x), y: Double(nodePositionOnScreen.y))
            
            //let hitPoint: CGPoint = CGPoint(x: 100, y: 100)
            
            
            //let hit = self.arView.hitTest(hitPoint, types: .existingPlaneUsingGeometry)
            
            
            /*let query = self.arView.raycastQuery(from: hitPoint, allowing: ARRaycastQuery.Target.existingPlaneInfinite, alignment: ARRaycastQuery.TargetAlignment.vertical)*/
            
            let laTmp = LocationNode(location: location)
            
            let locationNodeLocation = self.arView.locationOfLocationNode(laTmp)

            laTmp.updatePositionAndScale(setup: true,
                                          scenePosition: self.arView.currentScenePosition, locationNodeLocation: locationNodeLocation,
                                          locationManager: self.arView.sceneLocationManager) {
                
            }
            
            let nodeWorldPosition = laTmp.worldPosition
            
            let sceneLocation = simd_float3(self.arView.pointOfView!.worldPosition)
            let dirVec = simd_float3(nodeWorldPosition)
            print(sceneLocation)
            print(dirVec)
            let query = ARRaycastQuery.init(origin: sceneLocation, direction: dirVec,
                                allowing: ARRaycastQuery.Target.existingPlaneGeometry, alignment: ARRaycastQuery.TargetAlignment.vertical)
            
            if let result = self.arView.session.raycast(query).first {
                guard let planeAnchor = result.anchor as! ARPlaneAnchor? else {
                    print("ERROR: Not plane anchor")
                    return
                }
                print("hit")
                //self.locationManager.stopUpdatingLocation()
                /*laNode.position = SCNVector3(result.worldTransform.columns.3.x,
                                             result.worldTransform.columns.3.y,
                                             result.worldTransform.columns.3.z)
                laNode.eulerAngles = SCNVector3(laNode.eulerAngles.x + (Float.pi / 2), laNode.eulerAngles.y, laNode.eulerAngles.z)
                laNode.setWorldTransform(SCNMatrix4(result.worldTransform))*/
                
                laNode.annotationNode.scale = SCNVector3(0.2, 0.2, 0.2) // Need to scale based on distance?
                let x = CGFloat(planeAnchor.center.x)
                let y = CGFloat(planeAnchor.center.y)
                let z = CGFloat(planeAnchor.center.z)
                laNode.position = SCNVector3(x, y, z)
                laNode.eulerAngles.x = -.pi / 2
                laNode.constraints = []
                
                
            
                //self.arView.scene.rootNode.addChildNode(laNode)
                //let node = SCNNode(geometry: SCNBox(width:0.01, height:0.01, length:0.01, chamferRadius: 0))
                //self.arView.anchorMap[planeAnchor.identifier]?.addChildNode(node)
                self.arView.anchorMap[planeAnchor.identifier]?.addChildNode(laNode)
                
            } else {
                let billboardConstraint = SCNBillboardConstraint()
                billboardConstraint.freeAxes = SCNBillboardAxis.Y
                laNode.constraints = [billboardConstraint]
            
                // add node to AR scene
                self.arView.addLocationNodeWithConfirmedLocation(locationNode: laNode)
            }
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
