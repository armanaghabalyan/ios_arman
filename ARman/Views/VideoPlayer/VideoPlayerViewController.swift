//
//  VideoPlayerViewController.swift
//  ARtun
//
//  Created by Grigor Aghabalyan on 09.05.22.
//

import UIKit
import AVKit
import Photos
import AVFoundation

class VideoPlayerViewController: AVPlayerViewController {
    
    // MARK: - IBOutlets
        
    // MARK: - Variables
    var shareButton: UIBarButtonItem?
    
    var videoURL: URL?
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneButtonAction))
        let delateButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(delateButtonActtion))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonActtion))

        navigationItem.leftBarButtonItems = [doneButton]
        navigationItem.rightBarButtonItems = [shareButton!, delateButton]
        self.player?.play()
    }
    
    func showAlert(title: String?, message: String?) {
        
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (_) in
            
        }
        alertVC.addAction(okButton)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func doneButtonAction() {
        
        guard let videoURL = videoURL else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { saved, error in
            DispatchQueue.main.async { [weak self] in
                if !saved {
                    self?.showAlert(title: "Oops!", message: "Your video is not saved")
                }
                self?.dismiss(animated: true)
            }
        }
    }
    
    @objc func delateButtonActtion() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func shareButtonActtion() {
        guard let videoURL = videoURL else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            PHPhotoLibraryAuthorizationStatusHelper
                .checkAuthorizationAndPresentActivityController(toShare: videoURL, using: self!, barButtonItem: self?.shareButton)
        }
    }
}
