//
//  TSExtension.swift
//  Pods
//
//  Created by HKMac on 2017/7/12.
//
//

import UIKit


public extension CGFloat {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    /// 横屏缩放比例，标准比例6s
    static let wScale = CGFloat.screenWidth / 375
    /// 竖屏缩放比例，标准比例6s
    static let hScale = CGFloat.screenHeight / 667
}
public extension Int {
    var wScale: CGFloat {
        let f = CGFloat(self) * CGFloat.wScale
        let size = CGFloat.maximum(1, floor(f))
        return size
    }
    var hScale: CGFloat {
        let f = CGFloat(self) * CGFloat.hScale
        let size = CGFloat.maximum(1, floor(f))
        return size
    }
    
}


public extension UIFont {
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


public extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    
    /// 根控制器
    static var rootViewController: UIViewController {
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
    static func instance(_ identifier: String) -> UIViewController {
        return main.instantiateViewController(withIdentifier: identifier)
    }
    
    /// 起始控制器
    static let initial = main.instantiateInitialViewController()!
}

public extension UINib {
    static func viewsOfNib(name: String) -> [UIView] {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil) as! [UIView]
    }
    
    static func viewOfNib<T: UIView>(viewClass: T.Type) -> T {
        let className = NSStringFromClass(T.self)
        let nibName = className.components(separatedBy: ".").last!
        return Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as! T
    }
    static func nib<T: UIView>(viewClass: T.Type) -> UINib {
        let className = NSStringFromClass(T.self)
        let nibName = className.components(separatedBy: ".").last!
        return UINib(nibName: nibName, bundle: nil)
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
    
    /// base64编码
    var base64: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
    /// 时间戳转时间
    ///
    /// - Parameter format: 格式
    /// - Returns:
    func time(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        guard let timeInterval = Double(self) else { return "" }
        let date: Date
        if self.hasSuffix("000") {
            date = Date(timeIntervalSince1970: timeInterval / 1000)
        } else {
            date = Date(timeIntervalSince1970: timeInterval)
        }
        let now = Date()
        let interval = Int(now.timeIntervalSince(date))
        if interval < 60 {
            return "刚刚"
        }
        if interval < 60 * 60 {
            return "\(interval / 60)分钟前"
        }
        if interval < 60 * 60 * 24 {
            return "\(interval / 60 / 60)小时前"
        }
        if interval < 60 * 60 * 24 * 3 {
            return "\(interval / 60 / 60 / 24)天前"
        }
        return date.string(format: format)
    }
    
    /// 时间戳格式化
    ///
    /// - Parameter format: 格式
    /// - Returns:
    func date(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        guard let timeInterval = Double(self) else { return "" }
        let date: Date
        if self.hasSuffix("000") {
            date = Date(timeIntervalSince1970: timeInterval / 1000)
        } else {
            date = Date(timeIntervalSince1970: timeInterval)
        }
        return date.string(format: format)
    }
    
    /// 计算字符串高度
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - font: 字体
    /// - Returns: 高度
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let rect = (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return rect.size.height
    }
    
    /// 设备UUID
    static let deviceUUID = UIDevice.current.identifierForVendor!.uuidString
    
    /// 转Int
    var int: Int? {
        return Int(self)
    }
    
    /// 转Double
    var double: Double? {
        return Double(self)
    }
    
    /// 沙盒路径(home)/Documents
    static var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    /// 沙盒路径(home)/Library/Caches
    static var cachesPath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    /// 沙盒路径home
    static var homePath: String {
        return NSHomeDirectory()
    }
    /// 沙盒路径(home)/tmp
    static var tmpPath: String {
        return NSTemporaryDirectory()
    }
}

public extension Date {
    func string(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
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
    
    func border(cornerRadius: CGFloat, color: UIColor, width: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func corner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func shadow(color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.5
    }
}
