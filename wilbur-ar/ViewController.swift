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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let configuration = worldConfiguration {
          sceneView.debugOptions = .showFeaturePoints
          sceneView.session.run(configuration)
        }
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      sceneView.delegate = self
        
      let scene = SCNScene()
      sceneView.scene = scene

      setupObjectDetection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    
    let updateQueue = DispatchQueue(label: "com.example.wilbur-ar")
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor else {
            return
        }
        
        let referenceObject = objectAnchor.referenceObject
        
        // The following timer fires after 2 seconds, but every time when there found an anchor the timer is stopped.
        // So when there is no ARObjectAnchor found the timer will be completed and the current scene node will be deleted and the variable will set to nil
        updateQueue.async {
            if(self.timer != nil){
                self.timer.invalidate()
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                self.currentNode?.removeFromParentNode()
                self.currentNode = nil
            }
        }

         // Check if there is found a new image on the basis of the ARImageAnchorIdentifier, when found delete the current scene node and set the variable to nil
        if(currentARObjectAnchorIdentifier != objectAnchor.identifier &&
            currentARObjectAnchorIdentifier != nil
            && currentNode != nil){

            print("INSIDE CHECK FOR NEW OBJECT AND GONNA DELETE THE SCENE")
                //found new object
                currentNode!.removeFromParentNode()
                currentNode = nil
        }


        updateQueue.async {
            // If currentNode is nil, there is currently no scene node
            if(self.currentNode == nil){
                switch referenceObject.name {
                    case "daruma2":
                        self.handleFoundObject(objectAnchor: objectAnchor, node: node)
                        self.currentNode = self.scnNodeDaruma
                    default: break
                }
            }

            self.currentARObjectAnchorIdentifier = objectAnchor.identifier

            // Delete anchor from the session to reactivate the image recognition
            self.sceneView.session.remove(anchor: anchor)
        }
    }
    
    
    // The scnNodeDaruma variable will be the node to be added when the daruma object is found.
    private var scnNodeDaruma: SCNNode = SCNNode()
    // This variable holds the currently added scnNode (in this case scnNodeDaruma when the daruma object is found)
    private var currentNode: SCNNode? = nil
    // This variable holds the UUID of the found object Anchor that is used to add a scnNode
    private var currentARObjectAnchorIdentifier: UUID?
    // This variable is used to call a function when there is no new anchor added for 0.6 seconds
    private var timer: Timer!
    
    private func setupObjectDetection() {
        worldConfiguration = ARWorldTrackingConfiguration()

        guard let referenceObjects = ARReferenceObject.referenceObjects(
          inGroupNamed: "gallery", bundle: nil) else {
          fatalError("Missing expected asset catalog resources.")
        }

        worldConfiguration?.detectionObjects = referenceObjects
    }
    
    private func handleFoundObject(objectAnchor: ARObjectAnchor, node: SCNNode) {
        let name = objectAnchor.referenceObject.name!
        print("You found a \(name) object")
        node.addChildNode(cubeNode)
        cubeNode.position = node.position
//        cubeNode.position.y += 0.05
//        cubeNode.position.z -= 0.05
//        cubeNode.position.x += 0.05
        
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
    
    }
    
    let cubeNode = SCNNode(geometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0))
}
