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
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var arView: ARSCNView!
    
    var steps: [MKRoute.Step] = []
    var destinationLocation: CLLocationCoordinate2D!
    var locationService = LocationService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        /*
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)*/
        
        arView.delegate = self
        arView.showsStatistics = true
        arView.scene = SCNScene()
        let circleNode = createSphereNode(with: 0.2, color: .blue)
        circleNode.position = SCNVector3(0, 0, -1) // 1 meter in front of camera
        arView.scene.rootNode.addChildNode(circleNode)

        /* Attempt to use customer anchor but can use plane detection at another time
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        let transform = arView.session.currentFrame?.camera.transform ?? translation * translation
        
        let anchor = ARAnchor(transform: transform)
        arView.session.add(anchor: anchor)*/
        
        /*
        let plane = SCNNode(geometry: SCNPlane(width: 0.5, height: 0.5))
        plane.position = SCNVector3(0, 0, -2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        plane.geometry?.firstMaterial = material
        //SCNPlanes are rendered vertically by default
        arView.scene.rootNode.addChildNode(plane)*/
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
            let geometry = SCNSphere(radius: radius)
            geometry.firstMaterial?.diffuse.contents = color
            let sphereNode = SCNNode(geometry: geometry)
            return sphereNode
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        arView.scene.rootNode.childNodes[0].transform = SCNMatrix4Mult(arView.scene.rootNode.childNodes[0].transform, SCNMatrix4MakeRotation(Float(Double.pi) / 2, 1, 0, 0))
        arView.scene.rootNode.childNodes[0].transform = SCNMatrix4Mult(arView.scene.rootNode.childNodes[0].transform, SCNMatrix4MakeTranslation(0, 0, -2))
    }
}

struct NavigationService {
    
    func getDirections(destinationLocation: CLLocationCoordinate2D, request: MKDirections.Request, completion: @escaping ([MKRoute.Step]) -> Void) {
        var steps: [MKRoute.Step] = []
       
        let placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLocation.coordinate.latitude, longitude: destinationLocation.coordinate.longitude))
       
        request.destination = MKMapItem.init(placemark: placeMark)
        request.source = MKMapItem.forCurrentLocation()
        request.requestsAlternateRoutes = false
        request.transportType = .walking

        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if error != nil {
                print("Error getting directions")
            } else {
                guard let response = response else { return }
                for route in response.routes {
                    steps.append(contentsOf: route.steps)
                }
                completion(steps)
            }
        }
    }
}
