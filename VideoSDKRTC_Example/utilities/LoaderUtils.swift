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
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        viewControler.present(alert, animated: true, completion: nil)
    }
    
    class func loaderDismiss(viewControler: UIViewController) {
        viewControler.dismiss(animated: false, completion: nil)

    }
    
}
