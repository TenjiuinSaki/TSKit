//
//  TSGradientButton.swift
//  Pods
//
//  Created by HKMac on 2017/7/12.
//
//

import UIKit

public class TSGradientButton: UIButton {
    
    
    public convenience init(frame: CGRect, colors: [UIColor], endPoint: CGPoint = CGPoint(x: 1, y: 0)) {
        self.init(frame: frame)
        let gradientLayer = CAGradientLayer()
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        gradientLayer.colors = cgColors
        gradientLayer.frame = bounds
        gradientLayer.backgroundColor = UIColor.white.cgColor
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = endPoint
        gradientLayer.cornerRadius = bounds.size.height / 2
        gradientLayer.shadowColor = cgColors.last
        gradientLayer.shadowOffset = CGSize(width: 0, height: 3)
        gradientLayer.shadowRadius = 6
        gradientLayer.shadowOpacity = 0.5
        layer.addSublayer(gradientLayer)
    }
    
}
