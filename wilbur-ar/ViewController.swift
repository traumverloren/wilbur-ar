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
    
    // MARK: - Variables
    var waffleModel: SCNNode!
    var timer: Timer?
    let planeNode = PlaneNode()
    
    // MARK: - Lifecycle
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
        
        // Correct model orientation
        waffleModel.eulerAngles.x = 80
        
//        // Create physics for waffleModel
//        let shape = SCNPhysicsShape(node: waffleModel, options: nil)
//        waffleModel.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
//        waffleModel.physicsBody?.mass = 10
//        waffleModel.physicsBody?.friction = 0
//        waffleModel.physicsBody?.setResting(true)
        
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
        

        // 2 Add a plane to set waffle on top of.
        // Add planeNode that the text rests on cuz gravity
        let planePosition = 0.06
        planeNode.position.z =  -0.02
        planeNode.position.y = Float(planePosition)

        // Add planeNode to scene
        sceneView.scene.rootNode.addChildNode(planeNode)

        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)

        
        // 3 Adds Waffle async on main thread
        DispatchQueue.main.async {
            let modelClone = self.waffleModel.clone()
                
            var wafflePosition = Float(planePosition + 0.013)
            
            // position above AR ref object node
            modelClone.position.z =  -0.02
            modelClone.position.y =  wafflePosition

            // Add waffle model as a child of the AR Anchor node
            node.addChildNode(modelClone)
            
            // 4 Keep adding waffles every second
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
                print("Timer fired!")
                
                let waffleClone = self.waffleModel.clone()

                waffleClone.position.z =  -0.02
                wafflePosition += 0.015

                waffleClone.position.y = wafflePosition

                // Add waffle model as a child of the AR Anchor node
                node.addChildNode(waffleClone)
            }
        }
        
    }
}
