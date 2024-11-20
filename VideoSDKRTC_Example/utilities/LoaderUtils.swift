//
//  LoaderUtils.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 26/01/23.
//

import Foundation
import UIKit
import AVFoundation

class Utils: NSObject
{
    static var instance = Utils()
    
    class func loaderShow(viewControler: UIViewController) {
        DispatchQueue.main.async {
            if viewControler.presentedViewController is UIAlertController {
                print("Loader already presented, skipping")
                return
            }
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            viewControler.present(alert, animated: true) {
                print("Loader presented successfully")
            }
        }
    }
    
    class func loaderDismiss(viewControler: UIViewController) {
        DispatchQueue.main.async {
            guard let presentedVC = viewControler.presentedViewController as? UIAlertController else {
                print("No loader to dismiss")
                return
            }
            print("Dismissing loader: \(presentedVC)")
            presentedVC.dismiss(animated: true) {
                print("Loader dismissed successfully")
            }
        }
    }
}
