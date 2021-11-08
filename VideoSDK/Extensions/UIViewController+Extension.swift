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
}
