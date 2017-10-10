//
//  TSFilterView.swift
//  Pods
//
//  Created by HKMac on 2017/7/12.
//
//

import UIKit
import GLKit

public enum FilterType: String {
    case CIPhotoEffectInstant
    case CIPhotoEffectNoir
    case CIPhotoEffectTonal
    case CIPhotoEffectTransfer
    case CIPhotoEffectMono
    case CIPhotoEffectFade
    case CIPhotoEffectProcess
    case CIPhotoEffectChrome
}
public class TSFilterView: UIView {
    
    var ciImage: CIImage!
    var rectInPixels: CGRect!
    var ciContext: CIContext!
    var filterView: GLKView!
    public var filters = [CIFilter]()
    
    
    public convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        let eaglContext = EAGLContext(api: .openGLES2)!
        
        
        let scaleImage = image.scaleToFit(size: frame.size)
        ciImage = CIImage(image: scaleImage)!
        
        /// 缓冲视图
        filterView = GLKView(frame: bounds, context: eaglContext)
        addSubview(filterView)
        
        // 与OpenGLES绑定
        filterView.bindDrawable()
        
        // 定义绘制区域(像素描述)
        rectInPixels = CGRect(x: 0, y: 0, width: filterView.drawableWidth, height: filterView.drawableHeight)
        
        // 初始化CIImage的环境,指定在OpenGLES2上操作(此处只在GPU上操作)
        ciContext = CIContext(eaglContext: eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
        
        
        
    }

    public func drawImage() {
        if filters.count > 0 {
            var showImage = filters.first!.outImage(image: ciImage)
            for i in 1..<filters.count {
                showImage = filters[i].outImage(image: showImage)
            }
            ciContext.draw(showImage, in: rectInPixels, from: showImage.extent)
        } else {
            // 开始绘制
            ciContext.draw(ciImage, in: rectInPixels, from: ciImage.extent)
        }

        
        // 显示
        filterView.display()
    }
    public func addFilter(type: FilterType) {
        let filter = CIFilter(type: type)
        filters.append(filter)
    }
}

public extension CIFilter {
    func outImage(image: CIImage) -> CIImage {
        self.setValue(image, forKey: kCIInputImageKey)
        return self.outputImage!
    }
    
    convenience init(type: FilterType) {
        self.init(name: type.rawValue)!
    }
}
