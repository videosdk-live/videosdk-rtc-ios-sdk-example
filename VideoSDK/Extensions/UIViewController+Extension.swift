//
//  UIViewController+Extension.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 19/10/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
 
extension UIViewController {
    
    func showActionsheet(options: [MenuOption], fromView view: UIView, completion: @escaping (MenuOption) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = view
        }
        
        options.forEach {
            let action = UIAlertAction(title: $0.rawValue, style: $0.style) { action in
                let option = MenuOption(rawValue: action.title!)!
                completion(option)
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, autoDismiss: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showAlertWithTextField(title: String? = nil, message: String? = nil, value: String? = nil, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.keyboardType = .URL
            textField.text = value
        }
        
        alertController.addAction(.init(title: "Ok", style: .default, handler: { action in
            completion(alertController.textFields?.first?.text)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - NavigationBar Appearance

extension UIViewController {
        
    func setNavigationBarAppearance(_ navigationBar: UINavigationBar = UINavigationBar.appearance()) {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemDarkBackground
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 18)
            ]
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            
            navigationBar.tintColor = UIColor.white
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            
        } else {
            navigationBar.isTranslucent = false
            navigationBar.barStyle = .black
            navigationBar.barTintColor = UIColor.systemDarkBackground
            navigationBar.tintColor = UIColor.white
            
            // Disable shadow image to get rid of hideous white line
            navigationBar.shadowImage = UIImage()
            
            navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 18)
            ]
            
            // UIBarButtonItem
            let barButtonItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
            barButtonItem.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        }
    }
}
