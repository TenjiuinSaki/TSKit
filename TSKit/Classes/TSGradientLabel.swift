//
//  TSGradientLabel.swift
//  Pods
//
//  Created by HKMac on 2017/7/12.
//
//

import UIKit

public class TSGradientLabel: UIView {
    let label = UILabel()
    let gradientLayer = CAGradientLayer()
    
    public var text: String {
        set {
            label.text = newValue
        }
        get {
            return label.text ?? ""
        }
    }
    public var font: UIFont {
        set {
            label.font = newValue
        }
        get {
            return label.font
        }
    }
    
    
    public convenience init(frame: CGRect, colors: [UIColor], endPoint: CGPoint = CGPoint(x: 0, y: 1)) {
        self.init(frame: frame)
        
        addSubview(label)
        label.frame = bounds
        label.textAlignment = .center
        
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        gradientLayer.frame = bounds
        gradientLayer.colors = cgColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = endPoint
        
        gradientLayer.mask = label.layer
        layer.addSublayer(gradientLayer)
    }
    
}
