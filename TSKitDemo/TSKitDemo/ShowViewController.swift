//
//  ShowViewController.swift
//  TSKitDemo
//
//  Created by HKMac on 2017/7/12.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import GLKit
import TSKit

class ShowViewController: UIViewController {

    @IBOutlet weak var slider1: UISlider!
    
    var filterView: TSFilterView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let rect = CGRect(x: 0, y: 64, width: CGFloat.screenWidth, height: CGFloat.screenWidth)
        
        filterView = TSFilterView(frame: rect, image: #imageLiteral(resourceName: "201601031945423395"))
        view.addSubview(filterView)
        
        let names = CIFilter.filterNames(inCategory: kCICategoryGenerator)
        print(names)
        
        filterView.addFilter(type: .CIPhotoEffectTransfer)
//        filterView.addFilter(type: .CIHueAdjust)
        filterView.drawImage()
    }

    @IBAction func Slider1Changed(_ sender: UISlider) {
        filterView.filters[0].setValue(sender.value, forKey: kCIInputIntensityKey)
        filterView.drawImage()
    }
    @IBAction func slider2Changed(_ sender: UISlider) {
        filterView.filters[1].setValue(sender.value, forKey: kCIInputAngleKey)
        filterView.drawImage()
    }
}
