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

class ARViewController: UIViewController {

    @IBOutlet weak var arView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        let configuration = ARWorldTrackingConfiguration()
        
        arView.session.run(configuration)

        /* Attempt to use customer anchor but can use plane detection at another time
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        let transform = arView.session.currentFrame?.camera.transform ?? translation * translation
        
        let anchor = ARAnchor(transform: transform)
        arView.session.add(anchor: anchor)*/
        
        
        let plane = SCNNode(geometry: SCNPlane(width: 0.5, height: 0.5))
        plane.position = SCNVector3(0, 0, -2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        plane.geometry?.firstMaterial = material
        //SCNPlanes are rendered vertically by default
        arView.scene.rootNode.addChildNode(plane)
    }
}
