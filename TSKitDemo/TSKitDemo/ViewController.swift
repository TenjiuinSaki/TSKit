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

    func notif(n: Notification) {
        print(n.object ?? "没有内容")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        
        listen(name: "n1", action: #selector(notif(n:)))
        
        NotificationCenter.post(name: "n1")
        
        let str = "发数据库fksjf_34924290"
        let regex = "[\\u4e00-\\u9fa5\\w]{2,20}"        //数组字母下划线汉字2~20位
        
        let arr = str.regularMatch(with: regex)
        for str in arr {
            str.log()
        }
    
        let label = TSGradientLabel(frame: CGRect(x: 0, y: 100, width: CGFloat.screenWidth, height: 100), colors: [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)])
        label.font = UIFont.bold(size: 50)
        label.text = "Objective-C"
        view.addSubview(label)
        label.shadow(color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
        
        let button = TSGradientButton(frame: CGRect(x: 10, y: 300, width: CGFloat.screenWidth - 20, height: 50), colors: [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)])
//        button.setTitle("Swift", for: .normal)
        button.title = "Swift"
        view.addSubview(button)
        button.setAction(action: #selector(buttonClick))
//        button.addTarget(nil, action: #selector(buttonClick), for: .touchUpInside)
        
        let a = #selector(buttonClick)
        
//        let height = "发数据库fksjf_34924290发数据库fksjf_34924290发数据库fksjf_34924290发数据库fksjf_34924290".height(width: 100, font: UIFont.size(20))
  
        
//        let image = #imageLiteral(resourceName: "201509031750264023")
//        let size = view.bounds.size
//        let newImage = image.scale(size: size)
//        let imageView = UIImageView(image: newImage)
//        imageView.frame.origin = CGPoint(x: 0, y: 64)
//        view.addSubview(imageView)
//
//        let faceRects = newImage.faceRects()
//        for rect in faceRects {
//            
//            let faceImage = newImage.crop(at: rect).pixellate
//            let subImageView = UIImageView(image: faceImage)
//            subImageView.frame = rect
//            imageView.addSubview(subImageView)
//        }
//        let vc = UIViewController.instance(name: "ViewController")

        
        UIApplication.shared.checkVision(appId: "1166052753") { v in
            if v > UIApplication.shared.version {
//                UIApplication.shared.openUpdate(appId: "1166052753")
            }
        }
        
        let view1 = UIView(frame: CGRect(x: 100, y: 400, width: 300, height: 200))
        view1.backgroundColor = UIColor.red
        view1.x = 3
        view1.y = 380
        view1.maxX = CGFloat.screenWidth - 3
        view1.maxY = 500
        
        view1.size = CGSize(width: 100, height: 100)
        view1.bottom = CGFloat.screenHeight - 10
        view1.right = 320

        
        view1.log()
        
        view.addSubview(view1)
    }

    func buttonClick() {
//        performSegue(withIdentifier: "show_segue", sender: nil)
        performSegue(withIdentifier: "capture_segue", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

