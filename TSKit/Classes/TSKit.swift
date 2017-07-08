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

public struct TSScreen {
    public static let width = UIScreen.main.bounds.size.width
    public static let height = UIScreen.main.bounds.size.height
    public static let bounds = UIScreen.main.bounds
    
    /// 横屏缩放比例，标准比例6s
    public static let wScale = UIScreen.main.bounds.size.width / 375
    /// 竖屏缩放比例，标准比例6s
    public static let hScale = UIScreen.main.bounds.size.height / 667
}

public extension Int {
    var wScale: CGFloat {
        let f = CGFloat(self) * TSScreen.wScale
        let size = CGFloat.maximum(1, floor(f))
        return size
    }
    var hScale: CGFloat {
        let f = CGFloat(self) * TSScreen.hScale
        let size = CGFloat.maximum(1, floor(f))
        return size
    }
}


public struct TSFont {
    public static func size(_ size: Int, name: String? = nil, isBold: Bool = false) -> UIFont {
        if let name = name {
            return UIFont(name: name, size: size.wScale)!
        } else if isBold {
            return UIFont.boldSystemFont(ofSize: size.wScale)
        } else {
            return UIFont.systemFont(ofSize: size.wScale)
        }
    }
}


public struct TSStoryboard {
    private static let main = UIStoryboard(name: "Main", bundle: nil)
    
    /// 根控制器
    public static var rootViewController: UIViewController {
        set {
            UIApplication.shared.keyWindow?.rootViewController = newValue
        }
        get {
            return UIApplication.shared.keyWindow!.rootViewController!
        }
    }
    
    /// 实例化Storyboard控制器
    ///
    /// - Parameter identifier: String
    /// - Returns: UIViewController
    public static func instance(_ identifier: String) -> UIViewController {
        return main.instantiateViewController(withIdentifier: identifier)
    }
    
    /// 起始控制器
    public static func initial() -> UIViewController {
        return main.instantiateInitialViewController()!
    }
    
}

public struct TSNib {
    public static func viewsOfNib(name: String) -> [UIView] {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil) as! [UIView]
    }
    
    public static func viewOfNib<T: UIView>(viewClass: T.Type) -> T {
        let className = NSStringFromClass(T.self)
        let nibName = className.components(separatedBy: ".").last!
        return Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as! T
    }
}

public extension String {
    /// Unicode转化为汉字
    var decodeUnicode: String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: .utf8)!
        let returnStr = try! PropertyListSerialization.propertyList(from: tempData, options: [.mutableContainers, .mutableContainersAndLeaves], format: nil) as! String
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
    
    /// 匹配所有符合正则的字符串
    ///
    /// - Parameter regex: 正则表达式
    /// - Returns: String数组
    func regularMatch(with regex: String) -> [String] {
        var resArray = [String]()
        do {
            let regular = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
            let res = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, self.characters.count))
            for checkRes in res {
                resArray.append((self as NSString).substring(with: checkRes.range))
            }
        } catch {}
        return resArray
    }
    
    /// 验证字符串是否符合正则
    ///
    /// - Parameter regex: 正则表达式
    /// - Returns: Bool 真：符合
    func validate(with regex: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    var base64: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
}


public func TSLog<T>(message: T, fullName: String = #file, lineNum: Int = #line) {
    let path = fullName.components(separatedBy: "/").last!
    let fileName = path.components(separatedBy: ".").first!
    print("‼️\(fileName)-[第\(lineNum)行]:💋\(message)")
}




public struct TSDirPath {
    /// (home)/Documents
    public static var document: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    /// (home)/Library/Caches
    public static var caches: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    /// home
    public static var home: String {
        return NSHomeDirectory()
    }
    /// (home)/tmp
    public static var temporary: String {
        return NSTemporaryDirectory()
    }
}

public struct TSCache {
    /// 缓存
    static let cache = HybridCache(name: "SystemCache", config: Config(
        expiry: .date(Date().addingTimeInterval(60 * 5)),   //过期时间5分钟
        memoryCountLimit: 0,
        memoryTotalCostLimit: 0,
        maxDiskSize: 10000,                             //缓存大小10M
        cacheDirectory: TSDirPath.document + "/cache-in-documents"))
    
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

public extension UIView {
    
    /// 快照
    /// viewDidAppear后起作用
    /// - Returns: 图片
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public struct TSHttpRequest {
    
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


