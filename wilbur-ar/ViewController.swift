//
//  ViewController.swift
//  wilbur-ar
//
//  Created by Steph on 11/24/19.
//  Copyright © 2019 Steph. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import Dispatch

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    private var worldConfiguration: ARWorldTrackingConfiguration?

    override func viewDidLoad() {
      super.viewDidLoad()
        
      sceneView.autoenablesDefaultLighting = true
        
      sceneView.delegate = self
        
      // Uncomment to show statistics such as fps and timing information
      //sceneView.showsStatistics = true
        
      let scene = SCNScene()
        
      sceneView.scene = scene

      setupObjectDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let configuration = worldConfiguration {
          sceneView.debugOptions = .showFeaturePoints
          sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func setupObjectDetection() {
        worldConfiguration = ARWorldTrackingConfiguration()

        guard let referenceObjects = ARReferenceObject.referenceObjects(
          inGroupNamed: "gallery", bundle: nil) else {
          fatalError("Missing expected asset catalog resources.")
        }

        worldConfiguration?.detectionObjects = referenceObjects
    }
    
    
    /// - Tag: ARObjectAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      if let objectAnchor = anchor as? ARObjectAnchor {
        handleFoundObject(objectAnchor, node)
      }
    }

    private func handleFoundObject(_ objectAnchor: ARObjectAnchor, _ node: SCNNode) {
      // 1
      let name = objectAnchor.referenceObject.name!
      print("You found a \(name) object")

      // 2 Adds Text
      let text = SCNText(string: name, extrusionDepth: 0.1)
      let material = SCNMaterial()
      material.diffuse.contents = UIColor.red
      text.materials = [material]
      text.font = UIFont(name: "Helvetica", size: 1)
      
      let textNode = SCNNode()
      textNode.scale = SCNVector3(x: 0.02, y: 0.01, z: 0.01)
      textNode.geometry = text
      textNode.position = node.position
      textNode.position.y += 0.05
      textNode.position.x -= 0.018
      node.addChildNode(textNode)
        
      // 3 Adds waffle
      let waffleScene = SCNScene(named: "small-waffle.dae")
  
      guard let waffleNode = waffleScene?.rootNode.childNode(withName: "waffle", recursively: true) else { fatalError("waffle not found")}
        
        // TODO THIS DOESN"T WORKKKKKK
//      waffleNode.position = SCNVector3(0, 0.5, 0)
//      waffleNode.eulerAngles.x = 90
        
        
      node.addChildNode(waffleNode)
    }
}
