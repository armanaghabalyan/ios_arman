//
//  SelectVirtualObject.swift
//  ARman
//
//  Created by Arman Aghabalyan on 03.12.22.
//

import Foundation
import UIKit
import ARKit
import SceneKit


class SelectVirtualObject {
    
    static func selectVirtualObjectFromScan(didAdd node: SCNNode,
                                            imageAnchor: ARImageAnchor,
                                            virtualObjectManager: VirtualObjectManager ) {
        //print("referenceImage:\(referenceImage.name)")
        for definition in VirtualObjectManager.availableObjects where definition.folderName == imageAnchor.referenceImage.name?.dropLast(2) ?? "" {
            print("modelName:\(definition.modelName)")
            let object = VirtualObject(definition: definition)
            //object.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            _ = SCNVector3(imageAnchor.transform.columns.3.x,
                                      imageAnchor.transform.columns.3.y,
                                      imageAnchor.transform.columns.3.z)
            virtualObjectManager.loadVirtualObjectScan(object)
            object.scale = SCNVector3(definition.scaleX,
                                      definition.scaleY,
                                      definition.scaleZ)
            //object.position = position
            node.addChildNode(object)
            
        }
    }
}
