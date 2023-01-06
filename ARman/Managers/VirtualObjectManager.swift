//
//  VirtualObjectManager.swift
//  ARman
//
//  Created by Arman Aghabalyan on 03.12.22.
//

import Foundation
import ARKit

class VirtualObjectManager {
    
    weak var delegate: VirtualObjectManagerDelegate?
    
    var virtualObjects = [VirtualObject]()
    
    var lastUsedObject: VirtualObject?
    
    /// The queue with updates to the virtual objects are made on.
    var updateQueue: DispatchQueue
    
    init(updateQueue: DispatchQueue) {
        self.updateQueue = updateQueue
    }
    
    // MARK: - Resetting objects
    
    static let availableObjects: [VirtualObjectDefinition] = {
        guard let jsonURL = Bundle.main.url(forResource: "VirtualObjects", withExtension: "json") else {
            fatalError("Missing 'VirtualObjects.json' in bundle.")
        }
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode([VirtualObjectDefinition].self, from: jsonData)
        } catch {
            fatalError("Unable to decode VirtualObjects JSON: \(error)")
        }
    }()
    
    func removeAllVirtualObjects() {
        for object in virtualObjects {
            unloadVirtualObject(object)
        }
        virtualObjects.removeAll()
    }
    
    func removeVirtualObject(at index: Int) {
        let definition = VirtualObjectManager.availableObjects[index]
        guard let object = virtualObjects.first(where: { $0.definition == definition })
            else { return }
        
        unloadVirtualObject(object)
        if let pos = virtualObjects.firstIndex(of: object) {
            virtualObjects.remove(at: pos)
        }
    }
    
    private func setNewVirtualObjectPosition(_ object: VirtualObject, to pos: SIMD3<Float>, cameraTransform: matrix_float4x4) {
        let cameraWorldPos = cameraTransform.translation
        var cameraToPosition = pos - cameraWorldPos
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(cameraToPosition) > 10 {
            cameraToPosition = simd_normalize(cameraToPosition)
            cameraToPosition *= 10
        }
        
        object.simdPosition = cameraWorldPos + cameraToPosition
        object.recentVirtualObjectDistances.removeAll()
    }
    
    func loadVirtualObject(_ object: VirtualObject, to position: SIMD3<Float>, cameraTransform: matrix_float4x4) {
        self.virtualObjects.append(object)
        self.delegate?.virtualObjectManager(self, willLoad: object)
        
        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            
            // Immediately place the object in 3D space.
            self.updateQueue.async {
                self.setNewVirtualObjectPosition(object, to: position, cameraTransform: cameraTransform)
                self.lastUsedObject = object
                
                self.delegate?.virtualObjectManager(self, didLoad: object)
            }
        }
    }
    
    func loadVirtualObjectScan(_ object: VirtualObject) {
        self.virtualObjects.append(object)
        self.delegate?.virtualObjectManager(self, willLoad: object)
        
        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            
            // Immediately place the object in 3D space.
            self.updateQueue.async {
                self.lastUsedObject = object
                self.delegate?.virtualObjectManager(self, didLoad: object)
            }
        }
    }
    
    private func unloadVirtualObject(_ object: VirtualObject) {
        updateQueue.async {
            object.unload()
            object.removeFromParentNode()
            if self.lastUsedObject == object {
                self.lastUsedObject = nil
                if self.virtualObjects.count > 1 {
                    self.lastUsedObject = self.virtualObjects[0]
                }
            }
        }
    }
}

//// MARK: - Delegate
///
protocol VirtualObjectManagerDelegate: AnyObject {
    func virtualObjectManager(_ manager: VirtualObjectManager, willLoad object: VirtualObject)
    func virtualObjectManager(_ manager: VirtualObjectManager, didLoad object: VirtualObject)
    func virtualObjectManager(_ manager: VirtualObjectManager, transformDidChangeFor object: VirtualObject)
    func virtualObjectManager(_ manager: VirtualObjectManager, didMoveObjectOntoNearbyPlane object: VirtualObject)
    func virtualObjectManager(_ manager: VirtualObjectManager, couldNotPlace object: VirtualObject)
}

// Optional protocol methods

extension VirtualObjectManagerDelegate {
    func virtualObjectManager(_ manager: VirtualObjectManager, transformDidChangeFor object: VirtualObject) {}
    func virtualObjectManager(_ manager: VirtualObjectManager, didMoveObjectOntoNearbyPlane object: VirtualObject) {}
}
