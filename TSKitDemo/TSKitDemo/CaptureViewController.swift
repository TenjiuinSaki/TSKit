//
//  CaptureViewController.swift
//  TSKitDemo
//
//  Created by HKMac on 2017/7/13.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary

class CaptureViewController: UIViewController {

    let previewLayer = CALayer()            // 阅览层
    let captureSession = AVCaptureSession() // 捕获会话
    let filter = CIFilter(type: .CIPhotoEffectTransfer)
    
    var faceObject: AVMetadataFaceObject?   // 人脸信息
    
    var isRecoding = false                  // 是否在录制
    var assetWriter: AVAssetWriter?         // 文件写入器
    var assetWriterPixelBufferInput: AVAssetWriterInputPixelBufferAdaptor?
    var currentVideoDimensions: CMVideoDimensions?      // 当前视频尺寸
    var currentSampleTime: CMTime?                      // 当前视频时间
    var currentDevice: AVCaptureDevice?                 // 当前摄像头
    var currentDeviceInput: AVCaptureDeviceInput?       // 当前设备输入
    
    var currentImage: CIImage!                          // 当前图像
    
    var fileUrl = URL(fileURLWithPath: String.tmpPath).appendingPathComponent("temp.mov")
    
    lazy var context: CIContext = {
        let eaglContext = EAGLContext(api: .openGLES2)!
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(eaglContext: eaglContext, options: options)
    }()
    
    lazy var faceView: UIView = { [unowned self] in
        let faceView = UIView()
        faceView.border(cornerRadius: 3, color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), width: 1)
        self.view.addSubview(faceView)
        return faceView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        previewLayer.anchorPoint = .zero
        previewLayer.bounds = view.bounds
//        previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi / 2))
//        view.layer.addSublayer(previewLayer)
        view.layer.insertSublayer(previewLayer, at: 0)
            
        
        if TARGET_IPHONE_SIMULATOR == 1 {
//            showAlert(message: "不支持模拟器")
        } else {
            setupCaptureSession()       // 设置捕获活动
        }
    }

    func setupCaptureSession() {
        
        captureSession.beginConfiguration()     //开始活动配置
        
        // 高质量音视频输出
        captureSession.sessionPreset = .high
        
        // 获取后置摄像头
        let captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let device = captureDevice.devices.first else {
            
            return
        }
        currentDevice = device
        // 设置输入设备
        let deviceInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(deviceInput)
        currentDeviceInput = deviceInput
        
        // 设置输出数据
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey):
            Int(kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(dataOutput)
        
        // 设置输出线程
        let queue = DispatchQueue(label: "VideoQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        
        // 设置人脸识别
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = [.face]
        
        captureSession.commitConfiguration()        // 完成活动配置
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()               // 启动捕获活动
    }
    
    /// 屏幕翻转
    ///
    /// - Parameters:
    ///   - size: 屏幕翻转后的新的尺寸
    ///   - coordinator: 屏幕翻转过程中的一些信息,比如翻转时间等
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        previewLayer.bounds.size = size
    }
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        if currentImage == nil || isRecoding {
            return
        }
        sender.isEnabled = false
        captureSession.stopRunning()
        
        let cgImage = context.createCGImage(currentImage, from: currentImage.extent)!
        let image = UIImage(cgImage: cgImage)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { (success, error) in
            if let errorDescription = error?.localizedDescription {
                print("保存失败：\(errorDescription)")
            } else if success {
                print("保存成功")
            }
            sender.isEnabled = true
            self.captureSession.startRunning()
        })
        
    }
    
    @IBAction func shiftCamera(_ sender: UIBarButtonItem) {
        captureSession.removeInput(currentDeviceInput!)
        let position: AVCaptureDevice.Position = currentDevice!.position == .back ? .front : .back
        
        currentDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first
        
        currentDeviceInput = try! AVCaptureDeviceInput(device: currentDevice!)
        captureSession.addInput(currentDeviceInput!)
        let animation = CATransition()
        animation.duration = 0.25
        animation.type = kCATransitionFade
        animation.subtype = kCATruncationMiddle
        view.layer.add(animation, forKey: nil)
    }
    @IBAction func record(_ sender: UIBarButtonItem) {
        if isRecoding {     // 录制中
            isRecoding = false
            assetWriterPixelBufferInput = nil
            sender.title = "处理中"
            sender.isEnabled = false
            assetWriter?.finishWriting(completionHandler: { 
                self.saveMovie()
            })
        } else {
            if createWriter() {
                isRecoding = true
                sender.title = "停止"
            }
        }
    }
    func checkFile() {
        let manager = FileManager.default
        if manager.fileExists(atPath: fileUrl.path) {
            try! manager.removeItem(at: fileUrl)
        }
    }
    /// 创建文件写入器
    ///
    /// - Returns: 是否成功
    func createWriter() -> Bool {
        checkFile()
        do {
            assetWriter = try AVAssetWriter(url: fileUrl, fileType: .mov)
        } catch { return false }
        
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: currentVideoDimensions!.width,
            AVVideoHeightKey: currentVideoDimensions!.height
        ]
        
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = CGAffineTransform(rotationAngle: CGFloat
        .pi / 2)
        
        let bufferAttributes: [String: Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA,
            String(kCVPixelBufferWidthKey): currentVideoDimensions!.width,
            String(kCVPixelBufferHeightKey): currentVideoDimensions!.height,
            String(kCVPixelFormatOpenGLESCompatibility): kCFBooleanTrue
        ]
        assetWriterPixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: bufferAttributes)
        
        assetWriter!.add(assetWriterVideoInput)
        assetWriter!.startWriting()
        assetWriter!.startSession(atSourceTime: currentSampleTime!)
        
        return true
    }
    
    func saveMovie() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .authorized:
            PHPhotoLibrary.shared().performChanges({
                let att = try! FileManager.default.attributesOfItem(atPath: self.fileUrl.path)
                print(att)
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.fileUrl)
            }, completionHandler: { (success, error) in
                if let errorDescription = error?.localizedDescription {
                    print("写入视频错误：\(errorDescription)")
                } else if success {
                    print("写入视频成功")
                }
                
            })
        default:
            ()
//            showAlert(message: "授权访问相册")
        }
        
        
    }
}

extension CaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    /// 捕获输出缓冲
    ///
    /// - Parameters:
    ///   - captureOutput:
    ///   - sampleBuffer:
    ///   - connection:
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // 获取图像缓冲
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // 生成图片
        var outputImage = CIImage(cvImageBuffer: imageBuffer)
        // 滤镜图片
        outputImage = filter.outImage(image: outputImage)
        
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
        currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)       // 记录当前视频尺寸
        currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)            // 记录当前视频时间
        // 录制视频的处理
        if isRecoding {
            if assetWriterPixelBufferInput!.assetWriterInput.isReadyForMoreMediaData {
                var newPixelBuffer: CVPixelBuffer? = nil
                
                CVPixelBufferPoolCreatePixelBuffer(nil, assetWriterPixelBufferInput!.pixelBufferPool!, &newPixelBuffer)
                
                context.render(outputImage, to: newPixelBuffer!, bounds: outputImage.extent, colorSpace: nil)
                
                assetWriterPixelBufferInput!.append(newPixelBuffer!, withPresentationTime: currentSampleTime!)
            }
        }
        
        // 设置图片方向
        let transform: CGAffineTransform
        switch UIDevice.current.orientation {
        case .portrait:
            transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        case .landscapeLeft:
            transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        case .portraitUpsideDown:
            transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        default:
            transform = CGAffineTransform.identity
        }
        outputImage = outputImage.transformed(by: transform)
        currentImage = outputImage          // 记录当前图像
        
        // openGL 实时渲染
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        // 显示图像
        DispatchQueue.main.sync {       // 切换回主线程刷新UI
            previewLayer.contents = cgImage
            if let faceObject = faceObject {
                faceView.frame = changeFrame(rect: faceObject.bounds)
            } else {
                faceView.frame = .zero
            }
        }
        
        
    }
    // 转换坐标系
    func changeFrame(rect: CGRect) -> CGRect {
        let faceHeight = rect.size.width
        let faceWidth = rect.size.height
        let faceX = 1 - rect.origin.y  - faceWidth
        let faceY = rect.origin.x
        
        let x = CGFloat.screenWidth * faceX
        let y = CGFloat.screenHeight * faceY
        let width = CGFloat.screenWidth * faceWidth
        let height = CGFloat.screenHeight * faceHeight
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        faceObject = metadataObjects.first as? AVMetadataFaceObject
    }
}
