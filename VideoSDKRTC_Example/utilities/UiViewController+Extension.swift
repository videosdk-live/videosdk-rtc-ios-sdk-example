//
//  UiViewController+Extension.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 26/01/23.
//

import Foundation
import UIKit
import VideoSDKRTC
 
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
    
    func showQualitySelectionsheet(options: [MenuOption], fromView view: UIView, currentQuality: VideoQuality, completion: @escaping(VideoQuality) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = view
        }
        
        options.forEach {
            let action = UIAlertAction(title: $0.rawValue, style: $0.style) { action in
                let option = MenuOption(rawValue: action.title!)!
                switch option {
                case .high:
                    completion(.high)
                case .low:
                    completion(.low)
                case .medium:
                    completion(.medium)
                default:
                    completion(.high)
                }
            }
            
            if currentQuality.rawValue == action.title?.lowercased() {
                action.setValue(true, forKey: "checked")
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
    
    func showToast(message: String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            toastLabel.removeFromSuperview()
        }
    }
}

// MARK: - NavigationBar Appearance

extension UIViewController {
        
    func setNavigationBarAppearance(_ navigationBar: UINavigationBar = UINavigationBar.appearance()) {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "chatItemBackgroundColor")
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
            navigationBar.barTintColor = UIColor(named: "chatItemBackgroundColor")
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


extension String {
    func toDate() -> Date? {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
