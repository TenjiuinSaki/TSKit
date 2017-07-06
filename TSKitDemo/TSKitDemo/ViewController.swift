//
//  ViewController.swift
//  TSKitDemo
//
//  Created by HKMac on 2017/7/6.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import TSKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        TSLog(message: TSScreen.width)
        TSLog(message: TSDirPath.document)
//        TSCache.setDic(["key": "value"], key: "dic")
        TSLog(message: TSCache.getDic(key: "dic"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

