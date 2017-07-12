//
//  TSKit.swift
//  Pods
//
//  Created by HKMac on 2017/6/23.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import Cache
import Alamofire

public func TSLog<T>(message: T, fullName: String = #file, lineNum: Int = #line) {
    let path = fullName.components(separatedBy: "/").last!
    let fileName = path.components(separatedBy: ".").first!
    print("‼️\(fileName)-[第\(lineNum)行]:💋\(message)")
}


public struct TSCache {
    /// 缓存
    static let cache = HybridCache(name: "SystemCache", config: Config(
        expiry: .date(Date().addingTimeInterval(60 * 5)),   //过期时间5分钟
        memoryCountLimit: 0,
        memoryTotalCostLimit: 0,
        maxDiskSize: 10000,                             //缓存大小10M
        cacheDirectory: String.documentsPath + "/cache-in-documents"))
    
    public static func setDic(_ dic: [String: Any], key: String) {
        try? cache.addObject(JSON.dictionary(dic), forKey: key)
    }
    
    public static func getDic(key: String) -> [String: Any]? {
        let json: JSON? = cache.object(forKey: key)
        return json?.object as? [String: Any]
    }
    
    public static func setArray(_ arr: [Any], key: String) {
        try? cache.addObject(JSON.array(arr), forKey: key)
    }
    
    public static func getArray(key: String) -> [Any]? {
        let json: JSON? = cache.object(forKey: key)
        return json?.object as? [Any]
    }
}

public extension URLRequest {
    
    public static func get(url: String, params: [String: AnyObject]? = nil, log: Bool = false, success: ((NSObject) -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        
        guard NetworkReachabilityManager.init()!.isReachable else {
            fail?("无网络连接")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, method: .get, parameters: params).responseJSON { (res) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if res.result.isSuccess {
                if let data = res.result.value as? NSObject {
                    if log {
                        TSLog(message: "***************GET请求***************\nURL:\(url)\n" + data.description.decodeUnicode)
                    }
                    success?(data)
                } else {
                    fail?("数据解析失败")
                }
            } else {
                fail?("请求失败")
            }
        }
    }
    
    public static func post(url: String, params: [String: AnyObject]? = nil, log: Bool = false, success: ((NSObject) -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        
        guard NetworkReachabilityManager.init()!.isReachable else {
            fail?("无网络连接")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, method: .post, parameters: params).responseJSON { (res) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if res.result.isSuccess {
                if let data = res.result.value as? NSObject {
                    if log {
                        TSLog(message: "***************POST请求***************\nURL:\(url)\n" + data.description.decodeUnicode)
                    }
                    success?(data)
                } else {
                    fail?("数据解析失败")
                }
            } else {
                fail?("请求失败")
            }
        }
    }
}








