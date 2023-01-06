//
//  MainNavigationController.swift
//  ARman
//
//  Created by Grigor Aghabalyan on 04.12.22.
//

import UIKit

class MainNavigationController: UINavigationController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }

    deinit {
        print("dd: MainNavigationController")
    }
    
    // MARK: - Private methods
    fileprivate func setUI() {
    
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
       // appearance.backgroundColor = UIColor.mainBackground
//        navigationBar.setGradientBackground(colors: [.grad1, .grad2], startPoint: .topLeft, endPoint: .bottomRight)
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Medium", size: 18)!,
                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        
        navigationBar.tintColor = .white
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    
    func clearNavBarColor() {
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = .clear
    }
    
    func setNavBarColor() {
        
        navigationBar.tintColor = .white
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
    }
}

extension UIColor {
    
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}


extension UINavigationBar {
   
}
