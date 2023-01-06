//
//  VirtualObject.swift
//  ARman
//
//  Created by Arman Aghabalyan on 03.12.22.
//

import Foundation
import SceneKit
import ARKit

struct VirtualObjectDefinition: Codable, Equatable {
    let modelName: String
    let displayName: String
    let folderName: String
    let scaleX:Double
    let scaleY:Double
    let scaleZ:Double
    let particleScaleInfo: [String: Float]
    
    lazy var thumbImage: UIImage = UIImage(named: self.modelName)!
    
    init(modelName: String, displayName: String, particleScaleInfo: [String: Float] = [:],folderName: String,scaleX:Double,scaleY:Double,scaleZ:Double) {
        self.modelName = modelName
        self.displayName = displayName
        self.particleScaleInfo = particleScaleInfo
        self.folderName = folderName
    
        
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.scaleZ = scaleZ
    }
    
    static func ==(lhs: VirtualObjectDefinition, rhs: VirtualObjectDefinition) -> Bool {
        return lhs.modelName == rhs.modelName
            && lhs.displayName == rhs.displayName
            && lhs.particleScaleInfo == rhs.particleScaleInfo
            && lhs.folderName == rhs.folderName
            
            && lhs.scaleX == rhs.scaleX
            && lhs.scaleY == rhs.scaleY
            && lhs.scaleZ == rhs.scaleZ
    }
}

class VirtualObject: SCNReferenceNode, ReactsToScale {
    let definition: VirtualObjectDefinition
    
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
    
    var modelName: String {
        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
    }
    
    var allowedAlignments: [ARPlaneAnchor.Alignment] {
        if modelName == "sticky note" {
            return [.horizontal, .vertical]
        } else if modelName == "painting" {
            return [.vertical]
        } else {
            return [.horizontal]
        }
    }
    
    init(definition: VirtualObjectDefinition) {
        self.definition = definition
        guard let url = Bundle.main.url(forResource: "art.scnassets/\(definition.folderName)/\(definition.modelName)", withExtension: "dae")
            else { fatalError("can't find expected virtual object bundle resources") }
        super.init(url: url)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var anchor: ARAnchor?
    
    func reset() {
        recentVirtualObjectDistances.removeAll()
    }
    
    func isPlacementValid(on planeAnchor: ARPlaneAnchor?) -> Bool {
        if let anchor = planeAnchor {
            return allowedAlignments.contains(anchor.alignment)
        }
        return true
    }
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
    func reactToScale() {
        for (nodeName, particleSize) in definition.particleScaleInfo {
            guard let node = self.childNode(withName: nodeName, recursively: true), let particleSystem = node.particleSystems?.first
                else { continue }
            particleSystem.reset()
            particleSystem.particleSize = CGFloat(scale.x * particleSize)
        }
    }
}

extension VirtualObject {

    static func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        if node.parent != nil {
            return isNodePartOfVirtualObject(node.parent!)
        }
        
        return nil
    }
    
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor, using node: SCNNode) {
        // Test if the alignment of the plane is compatible with the object's allowed placement
       
        
        // Get the object's position in the plane's coordinate system.
        let planePosition = node.convertPosition(position, from: parent)
        
        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        // TODO: - Extent -> Center
        
        let minX: Float = anchor.center.x - anchor.center.x / 2 - anchor.center.x * tolerance
        let maxX: Float = anchor.center.x + anchor.center.x / 2 + anchor.center.x * tolerance
        let minZ: Float = anchor.center.z - anchor.center.z / 2 - anchor.center.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.center.z / 2 + anchor.center.z * tolerance
        
        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }
        
        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            position.y = anchor.transform.columns.3.y
            
            SCNTransaction.commit()
        }
    }
    
}

// MARK: - Protocols for Virtual Objects

protocol ReactsToScale {
    func reactToScale()
}

extension SCNNode {
    
    func reactsToScale() -> ReactsToScale? {
        if let canReact = self as? ReactsToScale {
            return canReact
        }
        
        if parent != nil {
            return parent!.reactsToScale()
        }
        
        return nil
    }
}

