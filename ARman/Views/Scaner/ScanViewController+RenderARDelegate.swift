//
//  ScanViewController+RenderARDelegate.swift
//  ARman
//
//  Created by Arman Aghabalyan on 04.12.22.
//

import Foundation
import Photos
import UIKit
import AVKit
import AVFoundation
import SCNRecorder

extension ScanViewController {
        
    // MARK: - Actions
    @objc func snapShotPhotoScreen() {
        let image = sceneView.snapshot()
        screenShotImageView.image = image
        UIView.animate(withDuration: 0.1) {
            self.screenShotView.alpha = 1
            self.screenShotView.isHidden = false
        }
        AudioServicesPlaySystemSound(1108)
        screenShotView.shake()
        if isScreeShot == false {
            setupTimer()
            isScreeShot = true
        }
    }
    
    @objc func videoRecordingScreen(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            print("Long press")
            recordingButton.setImage(UIImage(named: "record_scene_video_icon"), for: .normal)
            let scale = UIScreen.main.nativeScale
            let sceneSize = sceneView.bounds.size
            let size = CGSize(width: sceneSize.width * scale, height: sceneSize.height * scale)
            
            do {
                try sceneView.startVideoRecording(size: size)
            }
            catch {
                showAlert(title: "Error", message: "Something went wrong during video-recording preparation: \(error)")
            }
        }
        
        if gestureReconizer.state == UIGestureRecognizer.State.ended {
            recordingButton.setImage(UIImage(named: "take_scene_photo_icon"), for: .normal)
            sceneView.finishVideoRecording { url in
                DispatchQueue.main.async {
                    self.finishedExportingVideo(with: url.url)
                }
            }
            return
        }
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(ScanViewController.dismissView),
                                     userInfo: NSDate(), repeats: true)
    }
    
    @objc func dismissView () {
        if curentLimit == 0 {
            timer.invalidate()
            UIView.animate(withDuration: 0.1) {
                self.screenShotView.alpha = 1
                self.screenShotView.isHidden = true
            }
            curentLimit = 2
            isScreeShot = false
            if let image = screenShotImageView.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveComplete), nil)
            }
            
        }
        if curentLimit >= 0 {
            curentLimit -= 1
        }
    }
    
    @objc func saveComplete(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showAlert(title: "Photos access denied", message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots")
        }
    }
    
    // MARK: - Upload
    func finishedExportingVideo(with tempUrl: URL) {
      DispatchQueue.main.async { [weak self] in
        let player = VideoPlayerViewController()
        let navController = MainNavigationController(rootViewController: player)
        player.player = AVPlayer(url: tempUrl)
        player.modalPresentationStyle = .fullScreen
        player.videoURL = tempUrl
        self?.present(navController, animated: true)
      }
    }
}
