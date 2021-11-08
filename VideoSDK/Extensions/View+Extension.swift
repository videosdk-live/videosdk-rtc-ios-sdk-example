//
//  View+Extension.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func makeRounded() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.clipsToBounds = true
    }
}
