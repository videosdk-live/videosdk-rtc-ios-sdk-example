//
//  CALayer+Ext.swift
//  VipMe
//
//  Created by TBI-iOS-02 on 18/05/20.
//  Copyright © 2020 TBI-iOS-02. All rights reserved.
//

import UIKit


extension CALayer
{
    func makeSnapshot() -> UIImage?
    {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat, width: CGFloat)
    {
        let border = CALayer()
        
        switch edge
        {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.bounds.height - thickness, width: width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.bounds.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: width - thickness, y: 0, width: thickness, height: self.bounds.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
