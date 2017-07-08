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
        
        let str = "发数据库fksjf_34924290"
        let regex = "[\\u4e00-\\u9fa5\\w]{2,20}"        //数组字母下划线汉字2~20位
        
        let arr = str.regularMatch(with: regex)
        for str in arr {
            TSLog(message: str)
        }
        TSLog(message: str.validate(with: regex))
        
        let url = "http://192.168.2.105:8080/youzheng/mobile/publicInformation/lists"
        let params = ["paramType": 2] as [String: AnyObject]
        
        TSHttpRequest.post(url: url, params: params, log: true, success: { (data) in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

