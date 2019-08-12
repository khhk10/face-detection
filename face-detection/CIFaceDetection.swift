import Foundation
import UIKit

class CIFaceDetection {
    // 顔検出器
    let accuracy: [String : String]
    let detector: CIDetector
    
    init(vc: ViewController) {
        accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)!
    }
    
    // 顔検出
    func detectFace(ciInput: CIImage, imageView: UIImageView) {
        let featureArray = detector.features(in: ciInput)
        if featureArray.count == 0 { print("No faces was detected."); return }
        
        for feature in featureArray {
            let face = feature as! CIFaceFeature
            
            var rect = face.bounds // 顔
            var leftEye = face.leftEyePosition // 左目
            var rightEye = face.rightEyePosition // 右目
            var mouth = face.mouthPosition // 口
            print("bounds \(rect)")
            
            // 倍率
            let scale = imageView.frame.width / ciInput.extent.size.width
            print("scale : \(scale)")
            // let scale = min(imageView.frame.width / inputImage.size.width, imageView.frame.height / inputImage.size.height)
            // let offsetX = (imageView.bounds.width - ciInput.extent.size.width * scale) / 2
            // let offsetY = (imageView.bounds.height - ciInput.extent.size.height * scale) / 2
            print("ciInput : \(ciInput.extent.size)")
            
            // 補正
            rect.origin.y = ciInput.extent.size.height - rect.origin.y - rect.size.height
            leftEye.y = ciInput.extent.size.height - leftEye.y
            rightEye.y = ciInput.extent.size.height - rightEye.y
            mouth.y = ciInput.extent.size.height - mouth.y
            
            // サイズ変換
            rect.origin.x  = rect.origin.x * scale
            rect.origin.y  = rect.origin.y * scale
            rect.size.width = rect.size.width * scale
            rect.size.height = rect.size.height * scale
            leftEye = CGPoint(x: leftEye.x * scale, y: leftEye.y * scale)
            rightEye = CGPoint(x: rightEye.x * scale, y: rightEye.y * scale)
            mouth = CGPoint(x: mouth.x * scale, y: mouth.y * scale)
            
            let rectImage = drawRect(size: rect.size)
            let rectView = UIImageView(image: rectImage)
            
            let partsSize = CGSize(width: 5, height: 5)
            let parts = drawCircle(size: partsSize)
            let leftEyeView = UIImageView(image: parts)
            let rightEyeView = UIImageView(image: parts)
            let mouthView = UIImageView(image: parts)
            
            // 補正
            // rect.origin.x = rect.origin.x + offsetX
            // rect.origin.y = rect.origin.y + offsetY
            
            rectView.frame.origin.x = rect.origin.x
            rectView.frame.origin.y = rect.origin.y
            print("rectView : \(rectView.frame)")
            
            leftEyeView.frame.origin = CGPoint(x: leftEye.x - partsSize.width/2, y: leftEye.y - partsSize.height/2)
            rightEyeView.frame.origin = CGPoint(x: rightEye.x - partsSize.width/2, y: rightEye.y - partsSize.height/2)
            mouthView.frame.origin = CGPoint(x: mouth.x - partsSize.width/2, y: mouth.y - partsSize.height/2)
            
            imageView.addSubview(rectView)
            imageView.addSubview(leftEyeView)
            imageView.addSubview(rightEyeView)
            imageView.addSubview(mouthView)
        }
    }
    
    // 矩形を描画
    func drawRect(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        // print("rect: \(rect)")
        
        // 矩形
        let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(rect: newRect)
        context?.setFillColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
        context?.setStrokeColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        path.stroke()
        path.fill()
        
        // UIImage生成
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    // 円を描画
    func drawCircle(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        let circleRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(ovalIn: circleRect)
        context?.setFillColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
        context?.setStrokeColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        path.stroke()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}
