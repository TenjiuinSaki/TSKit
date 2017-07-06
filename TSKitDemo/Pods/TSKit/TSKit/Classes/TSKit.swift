//
//  TSKit.swift
//  Pods
//
//  Created by HKMac on 2017/6/23.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit

struct Screen {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let bounds = UIScreen.main.bounds
    
    /// 横屏缩放比例，标准比例6s
    static let wScale = UIScreen.main.bounds.size.width / 375
    /// 竖屏缩放比例，标准比例6s
    static let hScale = UIScreen.main.bounds.size.height / 667
}

extension Int {
    var wScale: CGFloat {
        let f = CGFloat(self) * Screen.wScale
        let size = CGFloat.maximum(1, floor(f))
        return size
    }
    var hScale: CGFloat {
        let f = CGFloat(self) * Screen.hScale
        let size = CGFloat.maximum(1, floor(f))
        return size
    }
}


struct Font {
    static func size(_ size: Int, name: String? = nil, isBold: Bool = false) -> UIFont {
        if let name = name {
            return UIFont(name: name, size: size.wScale)!
        } else if isBold {
            return UIFont.boldSystemFont(ofSize: size.wScale)
        } else {
            return UIFont.systemFont(ofSize: size.wScale)
        }
        
    }
}




struct Storyboard {
    private static let main = UIStoryboard(name: "Main", bundle: nil)
    
    static func setRootViewController(_ viewController: UIViewController) {
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
    }
    
    static func instance(_ identifier: String) -> UIViewController {
        return main.instantiateViewController(withIdentifier: identifier)
    }
    
    /// 起始控制器
    static func initial() -> UIViewController {
        return main.instantiateInitialViewController()!
    }
    
}

struct Xib {
    static func viewsOfXib(name: String) -> [UIView] {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil) as! [UIView]
    }
    
    static func viewOfXib<T: UIView>(viewClass: T.Type) -> T {
        let className = NSStringFromClass(T.self)
        let nibName = className.components(separatedBy: ".").last!
        return Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as! T
    }
}

extension String {
    /// Unicode转化为汉字
    var decodeUnicode: String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: .utf8)!
        let returnStr = try! PropertyListSerialization.propertyList(from: tempData, options: [.mutableContainers, .mutableContainersAndLeaves], format: nil) as! String
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
}

func info<T>(message: T, fullName: String = #file, lineNum: Int = #line) {
    let path = fullName.components(separatedBy: "/").last!
    let fileName = path.components(separatedBy: ".").first!
    print("‼️\(fileName)-[第\(lineNum)行]:💋\(message)")
}




struct DirPath {
    /// (home)/Documents
    static var document: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    /// (home)/Library/Caches
    static var caches: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    /// home
    static var home: String {
        return NSHomeDirectory()
    }
    /// (home)/tmp
    static var temporary: String {
        return NSTemporaryDirectory()
    }
}

