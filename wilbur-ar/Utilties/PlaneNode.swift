//
//  PlaneNode.swift
//  wilbur-ar
//
//  Created by Stephanie on 15.03.20.
//  Copyright © 2020 Steph. All rights reserved.
//

import SceneKit

public class PlaneNode: SCNNode {

    // MARK: - Lifecycle
    public override init() {
        super.init()
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Touch node configuration
        let box = SCNBox(width: 0.1, height: 0.001, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red

        geometry = box
        box.materials = [material]

        let boxShape = SCNPhysicsShape(geometry: box, options: nil)
        
        physicsBody = SCNPhysicsBody(type: .static, shape: boxShape)
    }
}
