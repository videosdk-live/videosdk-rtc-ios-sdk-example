//
//  UIView+Ext.swift
//  VipMe
//
//  Created by TBI-iOS-02 on 18/05/20.
//  Copyright © 2020 TBI-iOS-02. All rights reserved.
//

import UIKit


extension UIView
{
    func makeSnapshot() -> UIImage?
    {
        if #available(iOS 10.0, *)
        {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        }
        else
        {
            return layer.makeSnapshot()
        }
    }
    
    func setAspectRatio(_ ratio: CGFloat) -> NSLayoutConstraint
    {
        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: ratio, constant: 0)
    }
    
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat)
    {
        if #available(iOS 11.0, *)
        {
            clipsToBounds       = false //true
            layer.cornerRadius  = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        }
        else
        {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            
            layer.mask = mask
        }
    }
    
    
    func roundCornersToTop(cornerRadius: Double)
    {
        let path            = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer       = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path  = path.cgPath
        self.layer.mask     = maskLayer
    }
    
    func addShadow(shadowColor: UIColor ,shadowWidth:CGFloat, shadowHeight: CGFloat, shadowRadius: CGFloat, shadowOpacity: Float, clipsBounds : Bool = false)
    {
        self.clipsToBounds       = clipsBounds
        self.layer.shadowOffset  = CGSize(width: shadowWidth, height: shadowHeight)
        self.layer.shadowRadius  = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor   = shadowColor.cgColor
    }
    
    func addShadowToView(shadowColor: UIColor, shadowOpacity: CGFloat, shadowWidth: CGFloat, shadowHeight: CGFloat, shadowRadius: CGFloat)
    {
        self.layer.shadowColor   = shadowColor.cgColor
        self.layer.shadowOpacity = Float(shadowOpacity)
        self.layer.shadowOffset  = CGSize(width: shadowWidth, height: shadowHeight)
        self.layer.shadowRadius  = shadowRadius
        self.layer.shadowPath    = UIBezierPath(rect: self.bounds).cgPath
        self.layer.masksToBounds = false
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float)
    {
        layer.masksToBounds = false
        layer.shadowOffset  = offset
        layer.shadowColor   = color.cgColor
        layer.shadowRadius  = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor       = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2)
    {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue               = toValue
        animation.duration              = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode              = CAMediaTimingFillMode.forwards
        self.layer.add(animation, forKey: nil)
    }
    
    func addDashBorder(_ color: UIColor)
    {
        let color = color.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.name = "DashBorder"
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [2,4]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 4).cgPath
        
        self.layer.masksToBounds = false
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func setBorder(bkcolor: UIColor, underlineColor: UIColor)
    {
        self.layer.backgroundColor  = bkcolor.cgColor
        self.layer.masksToBounds    = false
        self.layer.shadowColor      = underlineColor.cgColor
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity    = 1.0
        self.layer.shadowRadius     = 0.0
    }
    
    
    
    enum ViewSide
    {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(toSide side: ViewSide , withColor color: CGColor, andThickness thickness: CGFloat)
    {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side
        {
        case .Left: border.frame    = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame   = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame     = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame  = CGRect(x: frame.minX, y: frame.maxY - thickness, width: frame.width, height: thickness); break
        }
        
        layer.addSublayer(border)
    }
    
    
    
    
    enum Direction: Int
    {
      case topToBottom = 0
      case bottomToTop
      case leftToRight
      case rightToLeft
    }
    
    /*
    func startShimmering()
    {
        let light = UIColor.init(white: 0, alpha: 0.1).cgColor
        let dark  = UIColor.black.cgColor
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors     = [dark, light, dark]
        gradient.frame      = CGRect(x: -self.bounds.size.width, y: 0, width: 3*self.bounds.size.width, height: self.bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1.0, y: 0.525)
        gradient.locations  = [0.4, 0.5, 0.6]
        self.layer.mask = gradient
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
        animation.fromValue   = [0.0, 0.1, 0.2]
        animation.toValue     = [0.8, 0.9, 1.0]
        animation.duration    = 2.0
        animation.repeatCount = Float.infinity
        
        gradient.add(animation, forKey: "shimmer")
    }
    
    func stopShimmering()
    {
        self.layer.mask = nil
    }
    */
    
    func startShimmering(animationSpeed: Float = 3.6, direction: Direction = .leftToRight, repeatCount: Float = Float.infinity)
    {
        
        // Create color  ->2
        let lightColor = UIColor.white.cgColor
        let blackColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        // Create a CAGradientLayer  ->3
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [lightColor, blackColor, lightColor]
        gradientLayer.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3 * self.bounds.size.width, height: 3 * self.bounds.size.height)
        
        switch direction
        {
        case .topToBottom:
          gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
          gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
          
        case .bottomToTop:
          gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
          gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
          
        case .leftToRight:
          gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
          gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
          
        case .rightToLeft:
          gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
          gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        }
        
        gradientLayer.locations =  [0.4, 0.5, 0.6] //[0.4, 0.6]
        self.layer.mask = gradientLayer
        
        // Add animation over gradient Layer  ->4
        CATransaction.begin()
        let animation           = CABasicAnimation(keyPath: "locations")
        animation.fromValue     = [0.0, 0.1, 0.2]
        animation.toValue       = [0.8, 0.9, 1.0]
        animation.duration      = CFTimeInterval(animationSpeed)
        animation.repeatCount   = repeatCount
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
        CATransaction.commit()
        
      }
      
      func stopShimmering()
      {
        self.layer.mask = nil
      }
      
    
    
    /// Flip view horizontally.
    func flipX() {
        transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
    }
    
    /// Flip view vertically.
    func flipY() {
        transform = CGAffineTransform(scaleX: transform.a, y: -transform.d)
    }
    
    
    //-----
    //BlinkAnimation
    
    func setBlink()
    {
        UIView.animate(withDuration: 0.02, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.alpha = 0.32
            self.perform(#selector(self.stopBlink), with: nil, afterDelay: 0.56)
        }) { (true) in }
    }
    
    @objc func stopBlink()
    {
        UIView.animate(withDuration: 0.02) {
            self.layer.removeAllAnimations()
            self.alpha = 1
        }
    }
    
    //---
    
    
    
}
