import Foundation
import UIKit
import Vision

class VisionFaceDetection {
    // 顔検出
    func visionFaceDetection(cgInput: CGImage?, ciInput: CIImage, imageView: UIImageView) {
        // リクエストを生成
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            // 処理完了後の処理
            for observation in request.results as! [VNFaceObservation] {
                print("\(observation)")
                if let landmarks = observation.landmarks {
                    // ランドマーク描画
                    self.drawLandmarks(landmarks: landmarks, ciImage: ciInput, imageView: imageView)
                }
                // 結果を描画
                self.drawFaceRectangle(observation: observation, ciImage: ciInput, imageView: imageView)
            }
        }
        guard let cgInput = cgInput else {
            return
        }
        // リクエストハンドラ
        let handler = VNImageRequestHandler(cgImage: cgInput, options: [:])
        do {
            // 実行
            try handler.perform([request])
        } catch let error {
            print("\(error)")
        }
    }
    
    // 顔領域の矩形を描画
    func drawFaceRectangle(observation: VNFaceObservation, ciImage: CIImage, imageView: UIImageView) {
        var rect: CGRect = observation.boundingBox
        
        // CIImageサイズ -> UIImageViewのサイズ
        let scale = imageView.frame.width / ciImage.extent.size.width
        
        // 元画像のスケールに合わせる
        rect.origin.x = ciImage.extent.size.width * rect.origin.x * scale
        rect.origin.y = ciImage.extent.size.height * rect.origin.y
        rect.size.width = ciImage.extent.size.width * rect.size.width * scale
        rect.size.height = ciImage.extent.size.height * rect.size.height
        // y座標を反転
        rect.origin.y = ciImage.extent.size.height - rect.origin.y - rect.size.height
        rect.origin.y = rect.origin.y * scale
        rect.size.height = rect.size.height * scale
        print("rect: \(rect)")
        
        // 描画
        let rectImage = drawRect(size: rect.size)
        let rectImageView = UIImageView(image: rectImage)
        // 座標指定
        rectImageView.frame.origin = CGPoint(x: rect.origin.x, y: rect.origin.y)
        imageView.addSubview(rectImageView)
    }
    
    // 矩形を描画
    func drawRect(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
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
    
    func drawLandmarks(landmarks: VNFaceLandmarks2D, ciImage: CIImage, imageView: UIImageView) {
        // CIImageサイズ -> UIImageViewのサイズ
        let scale = imageView.frame.width / ciImage.extent.size.width
        
        // 左目
        if let leftEye = landmarks.leftEye {
            for p in leftEye.pointsInImage(imageSize: ciImage.extent.size) {
                var point = p
                print("leftEye: \(point)")
                
                // 元画像のスケールに合わせる
                point.x = point.x * scale
                // point.y = ciImage.extent.size.height * point.y
                // y座標を反転
                point.y = ciImage.extent.size.height - point.y
                point.y = point.y * scale
                
                let leftImage = drawCircle(size: CGSize(width: 2, height: 2))!
                let leftImageView = UIImageView(image: leftImage)
                leftImageView.frame.origin = CGPoint(x: point.x - leftImage.size.width/2, y: point.y - leftImage.size.height/2)
                imageView.addSubview(leftImageView)
            }
        }
        // 右目
        if let rightEye = landmarks.rightEye {
            for p in rightEye.pointsInImage(imageSize: ciImage.extent.size) {
                var point = p
                print("rightEye: \(point)")
                
                // 元画像のスケールに合わせる
                point.x = point.x * scale
                // point.y = ciImage.extent.size.height * point.y
                // y座標を反転
                point.y = ciImage.extent.size.height - point.y
                point.y = point.y * scale
                
                let rightImage = drawCircle(size: CGSize(width: 2, height: 2))!
                let rightImageView = UIImageView(image: rightImage)
                rightImageView.frame.origin = CGPoint(x: point.x - rightImage.size.width/2, y: point.y + rightImage.size.height/2)
                imageView.addSubview(rightImageView)
            }
        }
    }
    
    // 特徴点を描画
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
