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
    
    var waffleModel: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X
        
        sceneView.delegate = self
        
        // Uncomment to show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        let waffleScene = SCNScene(named: "small-waffle.dae")!
        
        waffleModel =  waffleScene.rootNode.childNode(withName: "waffle", recursively: true)
        
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
    
    
    /*
     Called when a SceneKit node corresponding to a
     new AR anchor has been added to the scene.
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            handleFoundObject(objectAnchor, node)
        }
    }
    
    private func handleFoundObject(_ objectAnchor: ARObjectAnchor, _ node: SCNNode) {
        // 1
        let name = objectAnchor.referenceObject.name!
        print("You found a \(name) object")
        
        // 2 Adds Waffle async on main thread
        DispatchQueue.main.async {
            let modelClone = self.waffleModel.clone()
            // Correct model orientation
            modelClone.eulerAngles.x = 80
                
            modelClone.position = SCNVector3(0, 0.075, -0.02)

            // Add waffle model as a child of the AR Anchor node
            node.addChildNode(modelClone)
        }
    }
}
