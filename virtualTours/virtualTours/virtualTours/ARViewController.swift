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

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var arView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.delegate = self
        
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        // let configuration = ARWorldTrackingConfiguration()
        
        // arView.session.run(configuration)
        
//        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
//        cubeNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
//        arView.scene.rootNode.addChildNode(cubeNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // We're interested in vertical plane detection for the markers
        configuration.planeDetection = .vertical
        // Phone won't close while app is running
        UIApplication.shared.isIdleTimerDisabled = true
        // omnidirectional light
        self.arView.autoenablesDefaultLighting = true
        
        // Run view's session
        arView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
        // node for the plane
        let meshNode : SCNNode
        // node for the text on the plane
        let textNode : SCNNode
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        guard let meshGeometry = ARSCNPlaneGeometry(device: arView.device!)
            else {
                fatalError("Can't create plane geometry")
        }
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.6
        meshNode.name = "MeshNode"
        
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.blue
        
        node.addChildNode(meshNode)
        
        let textGeometry = SCNText(string: "Plane", extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 75)
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.name = "TextNode"
        
        textNode.simdScale = SIMD3(repeating: 0.0005)
        textNode.eulerAngles = SCNVector3(x: Float(-90 * Double.pi / 180), y: 0, z: 0)
        
        node.addChildNode(textNode)
        
        textNode.centerAlign()
            
            
        print("did add plane node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        if let planeGeometry = node.childNode(withName: "MeshNode", recursively: false)!.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }

    }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            // Present an error message to the user
            
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            // Inform the user that the session has been interrupted, for example, by presenting an overlay
            
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            // Reset tracking and/or remove existing anchors if consistent tracking is required
            
        }
    }


    extension SCNNode {
        func centerAlign() {
            let (min, max) = boundingBox
            let extents = ((max) - (min))
            simdPivot = float4x4(translation: SIMD3((extents / 2) + (min)))
        }
    }

    extension float4x4 {
        init(translation vector: SIMD3<Float>) {
            self.init(SIMD4(1, 0, 0, 0),
                      SIMD4(0, 1, 0, 0),
                      SIMD4(0, 0, 1, 0),
                      SIMD4(vector.x, vector.y, vector.z, 1))
        }
    }

    func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    func / (left: SCNVector3, right: Int) -> SCNVector3 {
        return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
    }


