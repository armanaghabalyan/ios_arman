//
//  BaseViewController.swift
//  ARman
//
//  Created by Grigor Aghabalyan on 04.12.22.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBindings()
        setLocalizations()
    }
    
    // MARK: - Private methods
    private func setBindings() {
    
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func backBtnAction(animated: Bool = true, completion: (() -> Void)? = nil) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: animated, completion: completion)
        }
        else if let owningNavigationController = navigationController {
            if owningNavigationController.popViewController(animated: animated) == nil {
                dismiss(animated: animated, completion: completion)
            }
        }
        else {
            dismiss(animated: animated, completion: completion)
        }
    }
    
    func addKeyboardHideOnViewTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        if let delegate = self as? UIGestureRecognizerDelegate {
            tap.delegate = delegate
        }
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setLocalizations() {
        
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
    
    func setNavBarColor() {
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func clearNavBarColor() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func clearNavigationBar(clear: Bool) {
        if clear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Medium", size: 18)!,
                                              NSAttributedString.Key.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
//            self.navigationController?.navigationBar.setGradientBackground(colors: [.clear, .clear], startPoint: .topLeft, endPoint: .bottomRight)
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Medium", size: 18)!,
                                              NSAttributedString.Key.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
//            self.navigationController?.navigationBar.setGradientBackground(colors: [.grad1, .grad2], startPoint: .topLeft, endPoint: .bottomRight)
        }
    }
}

