//
//  PHPhotoLibraryAuthorizationStatusHelper.swift
//  ARman
//
//  Created by Arman Aghabalyan on 04.12.22.
//

import Foundation
import Photos
import UIKit

class PHPhotoLibraryAuthorizationStatusHelper {
    static func checkAuthorizationAndPresentActivityController(toShare data: Any, using presenter: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.print]
            
            if let wPPC = activityViewController.popoverPresentationController {
                wPPC.barButtonItem = barButtonItem
            }
            presenter.present(activityViewController, animated: true, completion: nil)
        case .restricted, .denied:
            let libraryRestrictedAlert = UIAlertController(title: "Photos access denied",
                                                           message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.",
                                                           preferredStyle: UIAlertController.Style.alert)
            libraryRestrictedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            presenter.present(libraryRestrictedAlert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.print]
                    if let wPPC = activityViewController.popoverPresentationController {
                        wPPC.barButtonItem = barButtonItem
                    }
                    DispatchQueue.main.async {
                        presenter.present(activityViewController, animated: true, completion: nil)
                    }
                }
            })
        case .limited:
            break
        @unknown default:
            break
        }
    }
}
