//
//  ViewController.swift
//  TSKitDemo
//
//  Created by HKMac on 2017/7/6.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import TSKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        TSLog(message: TSScreen.width)
        TSLog(message: TSDirPath.document)
//        TSCache.setDic(["key": "value"], key: "dic")
        TSLog(message: TSCache.getDic(key: "dic"))
        
        let str = "发数据库fksjf_34924290"
        let regex = "[\\u4e00-\\u9fa5\\w]{2,20}"        //数组字母下划线汉字2~20位
        
        let arr = str.regularMatch(with: regex)
        for str in arr {
            TSLog(message: str)
        }
        TSLog(message: str.validate(with: regex))
        
        TSLog(message: "1499448144".time())
        
    
        let label = TSGradientLabel(frame: CGRect(x: 0, y: 100, width: TSScreen.width, height: 100), text: "Swift", colors: [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)], font: TSFont.size(50, isBold: true))
        view.addSubview(label)
        
//        label.border(cornerRadius: 50, color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), width: 2)
        label.shadow(color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
        
        let button = TSGradientButton(frame: CGRect(x: 10, y: 300, width: TSScreen.width - 20, height: 50), colors: [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)])
        button.setTitle("Objective-C", for: .normal)
        view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

