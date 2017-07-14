//
//  TSKit.swift
//  Pods
//
//  Created by HKMac on 2017/6/23.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit

public func TSLog<T>(message: T, fullName: String = #file, lineNum: Int = #line) {
    let path = fullName.components(separatedBy: "/").last!
    let fileName = path.components(separatedBy: ".").first!
    print("‼️\(fileName)-[第\(lineNum)行]:💋\(message)")
}










