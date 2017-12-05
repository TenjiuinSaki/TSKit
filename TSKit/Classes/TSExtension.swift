//
//  TSExtension.swift
//  Pods
//
//  Created by HKMac on 2017/7/12.
//
//

import UIKit

public extension UIScreen {
    static var type: Int {
        if CGFloat.screenHeight > 667 {
            return 2
        } else if CGFloat.screenHeight < 667 {
            return 0
        } else {
            return 1
        }
    }
}
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
    var double: Double {
        return Double(self)
    }
    var str: String {
        return String(self)
    }
}

public extension Double {
    func precision(p: Int) -> String {
        return String(format: "%.\(p)f", self)
    }
    ///最多保留两位
    var str2: String {
        return NSDecimalNumber(string: String(format: "%.2f", self)).stringValue
    }
    var str: String {
        return NSDecimalNumber(string: String(format: "%lf", self)).stringValue
    }
}


public extension UIFont {
    
    static func size(_ size: Int) -> UIFont {
        return UIFont.systemFont(ofSize: size.wScale)
    }
    static func name(_ name: String, size: Int) -> UIFont? {
        return UIFont(name: name, size: size.wScale)
    }
    static func bold(size: Int) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size.wScale)
    }
}

public extension UIApplication {
    var version: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    func checkVision(appId: String, complete: @escaping (String) -> Void) {
        
        let session = URLSession.shared
        let url = URL(string: "http://itunes.apple.com/cn/lookup?id=" + appId)!
        let task = session.dataTask(with: url) { (data, res, err) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                guard let dic = json as? NSDictionary,
                    let results = dic["results"] as? NSArray,
                    results.count > 0,
                    let result = results[0] as? NSDictionary,
                    let version = result["version"] as? String
                    else {
                        return
                }
                
                complete(version)
                
            }
        }
        task.resume()
    }
    
    func openUpdate(appId: String) {
        self.openURL(URL(string: "http://itunes.apple.com/cn/app/id" + appId)!)
    }
}

public extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    
    
    static func get(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
    /// 实例化Storyboard控制器
    ///
    /// - Parameter identifier: String
    /// - Returns: UIViewController
    func instance(_ identifier: String) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier)
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
            let res = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, self.count))
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
    
    /// 时间戳格式化
    ///
    /// - Parameter format: 格式
    /// - Returns:
    func date() -> Date? {
        guard let timeInterval = Double(self.retainFirst(count: 10)) else { return nil }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    /// 当前时间戳
    static func timestamp() -> String {
        let interval = Date().timeIntervalSince1970
        return String(interval)
    }
    
    func toDate(format: String = "yyyy-MM-dd HH:mm") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    func width(font: UIFont) -> CGFloat {
        let rect = (self as NSString).boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return rect.size.width
    }
    
    /// 计算字符串高度
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - font: 字体
    /// - Returns: 高度
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let rect = (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return rect.size.height
    }
    
    func attribute(color: UIColor, font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [
            NSAttributedStringKey.foregroundColor: color,
            NSAttributedStringKey.font: font
            ])
    }
    
    /// 设备UUID
    static var deviceUUID: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    /// 去掉后几位
    func removeLast(count: Int) -> String {
        guard self.count > count else {
            return self
        }
        return (self as NSString).substring(with: NSMakeRange(0, self.count - count))
    }
    
    func removeFirst(count: Int) -> String {
        guard self.count > count else {
            return self
        }
        return (self as NSString).substring(from: count)
    }
    
    /// 保留后几位
    func retainLast(count: Int) -> String {
        guard self.count > count else {
            return self
        }
        return (self as NSString).substring(with: NSMakeRange(self.count - count, count))
    }
    func retainFirst(count: Int) -> String {
        guard self.count > count else {
            return self
        }
        return (self as NSString).substring(to: count)
    }
    
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
    
    func time(format: String = "MM-dd HH:mm") -> String {
        let now = Date()
        let interval = Int(now.timeIntervalSince(self))
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
        return self.string(format: format)
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
    
    func removeSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    var viewController: UIViewController? {
        var next = self.next
        while next != nil {
            if next! is UIViewController {
                return next as? UIViewController
            }
            next = next?.next
        }
        return nil
    }
    
    var width: CGFloat {
        set {
            frame.size.width = newValue
        }
        get {
            return frame.width
        }
        
    }
    var height: CGFloat {
        set {
            frame.size.height = newValue
        }
        get {
            return frame.height
        }
    }
    
    var x: CGFloat {
        set {
            frame.origin.x = newValue
        }
        get {
            return frame.minX
        }
    }
    
    var y: CGFloat {
        set {
            frame.origin.y = newValue
        }
        get {
            return frame.minY
        }
    }
    
    var maxX: CGFloat {
        set {
            frame.size.width = newValue - x
        }
        get {
            return frame.maxX
        }
    }
    
    var maxY: CGFloat {
        set {
            frame.size.height = newValue - y
        }
        get {
            return frame.maxY
        }
    }
    
    var right: CGFloat {
        set {
            frame.origin.x = newValue - width
        }
        get {
            return frame.maxX
        }
    }
    
    var bottom: CGFloat {
        set {
            frame.origin.y = newValue - height
        }
        get {
            return frame.maxY
        }
    }
    
    var size: CGSize {
        set {
            frame.size = newValue
        }
        get {
            return frame.size
        }
    }
    
    var navigationController: UINavigationController? {
        return UIViewController.current.navigationController
    }
}
extension UIImageView {
    var imageColor: UIColor {
        set {
            self.tintColor = newValue
            self.image = image?.withRenderingMode(.alwaysTemplate)
        }
        get {
            return tintColor
        }
    }
}
public extension UIImage {
    
    /// 人脸识别，获取面部位置
    ///
    /// - Parameter scaleSize: 图片缩放
    /// - Returns:
    func faceRects() -> [CGRect] {
        guard let cgImage = self.cgImage else { return [] }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // 识别精度高，但识别速度慢、性能低
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        
        let features = detector.features(in: ciImage)
        
        // 转换坐标系 垂直翻转
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        // 平移变换
        transform = transform.translatedBy(x: 0, y: -self.size.height)
        
        var factRects = [CGRect]()
        for featrue in features {
            
            let faceFeatrue = featrue as! CIFaceFeature
            let faceRect = faceFeatrue.bounds.applying(transform)
            factRects.append(faceRect)
        }
        return factRects
    }
    
    /// 比例缩放图片
    ///
    /// - Parameter size: 尺寸
    /// - Returns:
    func scaleToFit(size: CGSize) -> UIImage {
        let imageWidth = self.size.width
        let imageHeight = self.size.height
        
        let widthScale = size.width / imageWidth
        let heightScale = size.height / imageHeight
        let scale = min(widthScale, heightScale)
        
        let scaleWidth = imageWidth * scale
        let scaleHeight = imageHeight * scale
        let targetSize = CGSize(width: scaleWidth, height: scaleHeight)
        
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func scaleToFill(size: CGSize) -> UIImage {
        let imageWidth = self.size.width
        let imageHeight = self.size.height
        
        let widthScale = size.width / imageWidth
        let heightScale = size.height / imageHeight
        let scale = max(widthScale, heightScale)
        
        let scaleWidth = imageWidth * scale
        let scaleHeight = imageHeight * scale
        let targetSize = CGSize(width: scaleWidth, height: scaleHeight)
        
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    
    /// 抠图
    ///
    /// - Parameter rect: 方位
    /// - Returns:
    func crop(at rect: CGRect) -> UIImage {
        let cgImage = self.cgImage!.cropping(to: rect)!
        return UIImage(cgImage: cgImage)
    }
    
    /// 马赛克
    var pixellate: UIImage {
        return self.filter(name: "CIPixellate")
    }
    var invert: UIImage {
        return self.filter(name: "CIColorInvert")
    }
    
    func filter(name: String) -> UIImage {
        let ciImage = CIImage(cgImage: self.cgImage!)
        let filter = CIFilter(name: name)!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = filter.outputImage!
        return UIImage(ciImage: outImage)
    }
    
    var gray: UIImage {
        let imageWidth = Int(self.size.width)
        let imageHeight = Int(self.size.height)
        
        let space = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: 0)!
        let rect = CGRect(origin: .zero, size: self.size)
        context.draw(self.cgImage!, in: rect)
        let cgImage = context.makeImage()!
        return UIImage(cgImage: cgImage)
    }
    
    func saveAlbum() {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
    }
}

public extension UIViewController {
    
    /// 通过字符串实例化控制器
    ///
    /// - Returns:
    static func instance(name: String) -> UIViewController? {
        let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"]
        guard let ns = nameSpace as? String else{
            return nil
        }
        let thisClass: AnyClass? = NSClassFromString(ns + "." + name)
        guard let thisClassType = thisClass as? UIViewController.Type else{
            return nil
        }
        return thisClassType.init()
    }
    
    /// 根控制器
    static var root: UIViewController? {
        set {
            UIApplication.shared.keyWindow?.rootViewController = newValue
        }
        get {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    static var current: UIViewController {
        return UIViewController.root!.getCurrentVC()
    }
    
    func getCurrentVC() -> UIViewController {
        var currentVC = self
        if let presentVC = self.presentedViewController {
            currentVC = presentVC.getCurrentVC()
        } else if self is UITabBarController {
            currentVC = (self as! UITabBarController).selectedViewController!.getCurrentVC()
        } else if self is UINavigationController {
            currentVC = (self as! UINavigationController).visibleViewController!.getCurrentVC()
        }
        return currentVC
    }
}
public extension UIButton {
    var title: String {
        set {
            setTitle(newValue, for: .normal)
        }
        get {
            return currentTitle ?? ""
        }
    }
    
    var image: UIImage? {
        set {
            setImage(newValue, for: .normal)
        }
        get {
            return image(for: .normal)
        }
    }
    
    var backgroundImage: UIImage? {
        set {
            setBackgroundImage(newValue, for: .normal)
        }
        get {
            return backgroundImage(for: .normal)
        }
    }
    var textfont: UIFont {
        set {
            titleLabel?.font = newValue
        }
        get {
            return titleLabel?.font ?? UIFont()
        }
    }
    var imageColor: UIColor {
        set {
            self.tintColor = newValue
            self.image = image?.withRenderingMode(.alwaysTemplate)
        }
        get {
            return tintColor
        }
    }
    var titleColor: UIColor? {
        set(newValue) {
            setTitleColor(newValue, for: .normal)
        }
        get {
            return titleColor(for: .normal)
        }
    }
}

public extension UITextField {
    var placeholderColor: UIColor {
        set {
            guard let placeholder = placeholder,
                let font = font else {
                    return
            }
            let attrString = NSAttributedString(string: placeholder, attributes: [
                .foregroundColor: newValue,
                .font: font])
            attributedPlaceholder = attrString
        }
        get {
            return UIColor()
        }
    }
}
public extension UILabel {
    var lineSpace: CGFloat {
        set {
            guard let text = text else {
                return
            }
            let graphStyle = NSMutableParagraphStyle()
            graphStyle.lineSpacing = newValue
            attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.paragraphStyle: graphStyle])
        }
        get {
            return 0
        }
    }
}
public extension UIColor {
    var image: UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(self.cgColor)
            context.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }
}

public extension NSObject {
    func log(fullName: String = #file, lineNum: Int = #line) {
        let path = fullName.components(separatedBy: "/").last!
        let fileName = path.components(separatedBy: ".").first!
        print("‼️\(fileName)-[第\(lineNum)行]:💋\(self)")
    }
    
    func listen(name: String, action: Selector) {
        NotificationCenter.default.addObserver(self, selector: action, name: NSNotification.Name(name), object: nil)
    }
}

public extension NotificationCenter {
    static func post(name: String, obj: Any? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(name), object: obj)
    }
}

public extension Timer {
    func open() {
        fireDate = NSDate.distantPast
    }
    func pause() {
        fireDate = NSDate.distantFuture
    }
}

public extension JSONDecoder {
    static func models<T: Decodable>(array: NSArray, type: T.Type) -> [T] {
        var models = [T]()
        
        for obj in array {
            do {
                let data = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                let model = try JSONDecoder().decode(type, from: data)
                models.append(model)
            } catch {
                print("转换失败")
            }
        }
        
        return models
    }
}

public extension URLRequest {
    static func get(urlStr: String, params: NSDictionary? = nil, timeout: TimeInterval = 10) -> URLRequest? {
        var urlStr = urlStr
        if let params = params {
            var paramStr = ""
            for (key, value) in params {
                paramStr.append("\(key)=\(value)&")
            }
            urlStr += ("?" + paramStr)
        }
        
        
        guard let str = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: str) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        
        return request
    }
    static func post(urlStr: String, params: NSDictionary? = nil, timeout: TimeInterval = 10) -> URLRequest? {
        guard let url = URL(string: urlStr) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        
        if let params = params {
            var paramStr = ""
            for (key, value) in params {
                paramStr.append("\(key)=\(value)&")
            }
            request.httpBody = paramStr.data(using: .utf8)
        }
        
        return request
    }
}
