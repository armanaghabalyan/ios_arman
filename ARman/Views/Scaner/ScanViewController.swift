//
//  ScanViewController.swift
//  ARMegic
//
//  Created by Arman Aghabalyan on 10/17/18.
//  Copyright © 2018 Grigor Aghabalyan. All rights reserved.
//

import ARKit
import SceneKit
import UIKit
import SCNRecorder

class ScanViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var restartSessionBt: UIButton!
    
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var screenShotView: UIView!
    @IBOutlet weak var screenShotImageView: UIImageView!
    
    // MARK: - Variables
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    private var notificationObserver: NSObjectProtocol?
    private var imageTargets: [SCNNode] = []
    private var uiImages: [CGImage] = []
  
    private var customReferenceSet = Set<ARReferenceImage>()
    private let imageFetchingGroup = DispatchGroup()
    
    private var currentImage: String?
    private var lastImage: String?
    
    private var virtualObjectManager: VirtualObjectManager!
    
    var isScreeShot = false
    var timer = Timer()
    var curentLimit = 2
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        virtualObjectManager = VirtualObjectManager(updateQueue: updateQueue)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.prepareForRecording()
        
        setupGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        session.pause()
    }
    
    // MARK: - Setups
    
    func resetTracking() {
        imageTargets.removeAll()
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        //configuration.trackingImages = customReferenceSet
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    func setupGestureRecognizer() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScanViewController.snapShotPhotoScreen))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(ScanViewController.videoRecordingScreen))
        
        tapGesture.numberOfTapsRequired = 1
        longGesture.minimumPressDuration = 0.5
        
        //longGesture.delaysTouchesBegan = false
        recordingButton.addGestureRecognizer(longGesture)
        recordingButton.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @IBAction func restartSession(_ sender: UIButton) {
        resetTracking()
    }
}

extension ScanViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            switch referenceImage.name?.last {
            case "i":
                self.notificationObserver = PlayVideoContentHelper.playVideoNode(didAdd: node,
                                                                                 sceneView: self.sceneView,
                                                                                 imageAnchor: referenceImage,
                                                                                 fileName: "art.scnassets/videos/\(referenceImage.name!)")
            case "o":
                SelectVirtualObject.selectVirtualObjectFromScan(didAdd: node,
                                                                imageAnchor: imageAnchor,
                                                                virtualObjectManager: self.virtualObjectManager)
            case .none:
                break
            case .some(_):
                break
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            if imageAnchor.referenceImage.name?.last == "i" {
                if imageAnchor.isTracked {
                    PlayVideoContentHelper.playPlayer()
                    print("Node Is Visible")
                }else {
                    print("Node Is Not Visible")
                    PlayVideoContentHelper.pausePlayer()
                    resetTracking()
                }
            }
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
}
