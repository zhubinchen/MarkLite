//
//  CLPhotoRecorder.swift
//  Sport-Swift
//
//  Created by 夜猫子 on 2017/5/21.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit
import AVFoundation

/// 设置代理
protocol CLPhotoRecorderDelegate {
    
    /// 在拍照照片上面添加水印找
    ///
    /// - Parameter waterImage: self
    func phontWaterImage(waterImage:CLPhotoRecorder)
}

class CLPhotoRecorder: UIView {
    
    /// 代理属性
    var delegate:CLPhotoRecorderDelegate?
    
    /// 预览图层
    fileprivate var preView:UIView?
    
    /// 输入设备（摄像头）
    fileprivate var captureDeviceInput:AVCaptureDeviceInput?
    
    /// 输出设备（静态图像输出）iOS10.0之前
    fileprivate var captureStillImageOutput: AVCaptureStillImageOutput?
    
    /// 拍摄会话
    fileprivate var captureSession:AVCaptureSession?
    
    /// 预览图层layer
    fileprivate var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    
}


// MARK: - 外部调用的公开方法
extension CLPhotoRecorder {
    
    /// 自定义构造方法
    ///
    /// - Parameter preView: 预览图层
    func initWithPreView(preView:UIView) {
        self.preView = preView
        //搭建拍摄会话
        setupSession()
    }
    
    /// 开始拍照
    func startCamera() {
        captureSession?.startRunning()
        
    }
    
    /// 结束拍照
    func stopCamrea() {
        captureSession?.stopRunning()
        
    }
    
    /// 前后摄像头对调
    func switchCamera() {
        
    }
    
    /// 拍照
    ///
    /// - Parameter completion: 闭包回调
    func capture(completion:@escaping (_ comImage : UIImage) ->()) {
        let arr = captureStillImageOutput?.connections
        let connection: AVCaptureConnection = arr?.last as! AVCaptureConnection
        //1.从输出设备中获取数据(异步操作：拍摄过程内存环境很复杂，同步达不到要求)
        /**
         Connection：输出设备与输入设备之间的连接
         completionHandler：完成回调
         */
        captureStillImageOutput?.captureStillImageAsynchronously(from: connection, completionHandler: { (imageDataSampleBuffer, error) in
            

        })
    }
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        
        
        if didFinishSavingWithError == nil {
            
            print("图片保存成功")
        }
        
    }
}


extension CLPhotoRecorder {
    
    /// 对指定照片裁切图片
    ///
    /// - Parameter image: 图片
    /// - Returns: 返回裁切号的图片
    fileprivate func cutImageWithSourceImage(image:UIImage) -> UIImage {
        UIGraphicsBeginImageContext((self.preView?.bounds.size)!)
        let width:Float = Float(UIScreen.main.bounds.size.width - (self.preView?.bounds.size.width)!)
        let height:Float = Float(UIScreen.main.bounds.size.height - (self.preView?.bounds.size.height)!)
        image.draw(in: (self.preView?.frame.insetBy(dx: CGFloat(-width / 2), dy: CGFloat(-height / 2)))!)
        if ((self.delegate) != nil) {
            self.delegate?.phontWaterImage(waterImage: self)
        }
        let resuleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resuleImage!
        
    }
    
    /// 搭建拍摄环境会话
    fileprivate func setupSession() {
        var device:AVCaptureDevice?
        let arr = AVCaptureDevice.devices();

    }
    
}
