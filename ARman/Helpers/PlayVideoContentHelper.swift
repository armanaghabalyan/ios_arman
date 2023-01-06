//
//  PlayVideoContentHelper.swift
//  ARman
//
//  Created by Arman Aghabalyan on 03.12.22.
//

import ARKit
import SceneKit
import UIKit

enum VideoType {
    case chromaKey
    case normal
}

class PlayVideoContentHelper {
    
    static var player = AVPlayer()
    
    static func playVideoNode(didAdd node: SCNNode,
                              sceneView: SCNView,
                              imageAnchor: ARReferenceImage,
                              fileName: String,
                              format: String = "mp4",
                              videoType: VideoType = .normal,
                              correctWidth: CGFloat = 0.0,
                              correctHeight: CGFloat = 0.0) -> NSObjectProtocol? {
        
        var notificationObserver: NSObjectProtocol?
        
        let filePath = Bundle.main.path(forResource: fileName, ofType: format)
        let videoURL = NSURL(fileURLWithPath: filePath!)
        player = AVPlayer(url: videoURL as URL)
        
        let videoNode = SCNNode()
        videoNode.geometry = SCNPlane(width: imageAnchor.physicalSize.width + correctWidth,
                                      height: imageAnchor.physicalSize.height + correctHeight)
        
        videoNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        videoNode.geometry?.firstMaterial?.diffuse.contents = player
        videoNode.geometry?.firstMaterial?.isDoubleSided = true
        
        switch videoType {
        case .chromaKey:
            let chromaKeyMaterial = ChromaKeyMaterial()
            chromaKeyMaterial.diffuse.contents = player
            videoNode.geometry!.materials = [chromaKeyMaterial]
        case .normal:
            break
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            player.seek(to:CMTimeMakeWithSeconds(1, preferredTimescale: 1000))
            player.play()
        }
        
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main){ _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        node.addChildNode(videoNode)
        sceneView.scene?.rootNode.addChildNode(node)
        node.name = "videoNode"
        return notificationObserver ?? nil
    }
    
    static func pausePlayer() {
        player.pause()
    }
    
    static func playPlayer() {
        player.play()
    }
    
    static func playVideoNode2(didAdd node: SCNNode, sceneView: SCNView, imageAnchor: ARReferenceImage, fileName: String, type: String){
      
        let videoNode = SCNNode()
        videoNode.geometry = SCNPlane(width: imageAnchor.physicalSize.width +  0.66,
                                      height: imageAnchor.physicalSize.height + 0.05)
        
        videoNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        videoNode.geometry?.firstMaterial?.diffuse.contents = player
        videoNode.geometry?.firstMaterial?.isDoubleSided = true
        
        let chromaKeyMaterial = ChromaKeyMaterial()
        videoNode.geometry!.materials = [chromaKeyMaterial]
        
        if let videoURL = Bundle.main.url(forResource: fileName, withExtension: type){
            setupVideoOnNode(videoNode, fromURL: videoURL)
        }
        
        node.addChildNode(videoNode)
        sceneView.scene?.rootNode.addChildNode(node)
    }
    
   static func setupVideoOnNode(_ node: SCNNode, fromURL url: URL){
        
        //1. Create An SKVideoNode
        var videoPlayerNode: SKVideoNode!
        
        //2. Create An AVPlayer With Our Video URL
        let videoPlayer = AVPlayer(url: url)
        
        //3. Intialize The Video Node With Our Video Player
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        
        //4. Create A SpriteKitScene & Postion It
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
        //6. Set The Nodes Geoemtry Diffuse Contenets To Our SpriteKit Scene
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        
        //5. Play The Video
        videoPlayerNode.play()
        videoPlayer.volume = 1
    }
}
