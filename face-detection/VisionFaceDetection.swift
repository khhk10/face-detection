import Foundation
import UIKit
import Vision

class VisionFaceDetection {
    // 呼び出し元のビューコントローラ
    let viewController: ViewController
    
    init(vc: ViewController) {
        viewController = vc
    }
    
    // 顔検出
    func visionFaceDetection(cgInput: CGImage?, ciInput: CIImage, imageView: UIImageView) {
        let imageViewSize = imageView.frame.size
        // リクエストを生成
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            // 処理完了後の処理
            for observation in request.results as! [VNFaceObservation] {
                print("observation! : \(observation)")
                DispatchQueue.main.async {
                    // バウンディングボックスを描画
                    let boundBoxLayer = self.boundBoxLayer(boundBox: observation.boundingBox, ciImageSize: ciInput.extent.size, imageViewSize: imageViewSize)
                    imageView.layer.addSublayer(boundBoxLayer)
                    // ランドマークを描画
                    if let landmarks = observation.landmarks {
                        let landmarkLayer = self.landmarkLayer(landmarks: landmarks, boundBox: observation.boundingBox, ciImageSize: ciInput.extent.size, imageViewSize: imageViewSize)
                        imageView.layer.addSublayer(landmarkLayer)
                        // self.drawLandmarks(landmarks: landmarks, ciImage: ciInput, imageView: imageView)
                    }
                }
                // 結果を描画
                // self.drawFaceRectangle(observation: observation, ciImage: ciInput, imageView: imageView)
            }
        }
        guard let cgInput = cgInput else {
            return
        }
        // リクエストハンドラ
        let handler = VNImageRequestHandler(cgImage: cgInput, options: [:])
        // ハンドラにリクエストを送信
        DispatchQueue.global(qos: .userInitiated).async {
            // バックグラウンドで実行
            // 引数の.userIntiatedは、優先付けするためのもの -> 応答性の向上とリソースの効率化
            do {
                // 実行
                try handler.perform([request])
            } catch let error {
                print("failed to perform image request: \(error)")
                return
            }
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
    
    // バウンディングボックスを描画
    func boundBoxLayer(boundBox: CGRect, ciImageSize: CGSize, imageViewSize: CGSize) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        var rect = boundBox
        // CIImageサイズ -> UIImageViewサイズへ
        let scale = imageViewSize.width / ciImageSize.width
        
        // boundBox -> UIImageViewサイズ
        rect.origin.x = rect.origin.x * ciImageSize.width * scale
        rect.origin.y = rect.origin.y * ciImageSize.height
        rect.size.width = rect.size.width * ciImageSize.width * scale
        rect.size.height = rect.size.height * ciImageSize.height
        
        // y座標を反転
        rect.origin.y = ciImageSize.height - rect.origin.y - rect.size.height
        rect.origin.y = rect.origin.y * scale
        rect.size.height = rect.size.height * scale
        print("rect: \(rect)")
        
        // 矩形
        let path = UIBezierPath(rect: rect)
        shapeLayer.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor
        shapeLayer.fillColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1).cgColor
        shapeLayer.path = path.cgPath
        
        return shapeLayer
    }
    
    // ランドマークを描画
    func landmarkLayer(landmarks: VNFaceLandmarks2D, boundBox: CGRect, ciImageSize: CGSize, imageViewSize: CGSize) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1).cgColor
        shapeLayer.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor
        // パス
        let path = UIBezierPath()
        // 左目
        if let leftEye = landmarks.leftEye {
            var leftEyes = leftEye.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: leftEyes.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            leftEyes.removeFirst()
            for point in leftEyes {
                print("left eye point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 右目
        if let rightEye = landmarks.rightEye {
            var rightEyes = rightEye.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: rightEyes.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            rightEyes.removeFirst()
            for point in rightEyes {
                print("right eye point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 左眉
        if let leftEyeBrow = landmarks.leftEyebrow {
            var leftEyeBrows = leftEyeBrow.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: leftEyeBrows.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            leftEyeBrows.removeFirst()
            for point in leftEyeBrows {
                print("left eye point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 右眉
        if let rightEyeBrow = landmarks.rightEyebrow {
            var rightEyeBrows = rightEyeBrow.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: rightEyeBrows.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            rightEyeBrows.removeFirst()
            for point in rightEyeBrows {
                print("left eye point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 鼻
        if let nose = landmarks.nose {
            var nosePoints = nose.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: nosePoints.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            nosePoints.removeFirst()
            for point in nosePoints {
                print("nose point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 唇（内）
        if let innerLip = landmarks.innerLips {
            var innerLips = innerLip.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: innerLips.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            innerLips.removeFirst()
            for point in innerLips {
                print("nose point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 唇（外）
        if let outerLip = landmarks.outerLips {
            var outerLips = outerLip.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: outerLips.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            outerLips.removeFirst()
            for point in outerLips {
                print("nose point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        // 顔の輪郭
        if let faceContour = landmarks.faceContour {
            var faceContours = faceContour.pointsInImage(imageSize: ciImageSize)
            let firstPoint = convertPoints(p: faceContours.first!, ciImageSize: ciImageSize, imageViewSize: imageViewSize)
            path.move(to: firstPoint) // 始点に移動
            faceContours.removeFirst()
            for point in faceContours {
                print("nose point: \(point)")
                let newPoint = convertPoints(p: point, ciImageSize: ciImageSize, imageViewSize: imageViewSize) // 座標変換
                path.addLine(to: newPoint)
            }
        }
        shapeLayer.path = path.cgPath
        
        return shapeLayer
    }
    
    func convertPoints(p: CGPoint, ciImageSize: CGSize, imageViewSize: CGSize) -> CGPoint {
        var point = p
        // CIImageサイズ -> UIImageViewサイズへ
        let scale = imageViewSize.width / ciImageSize.width
        
        // boundBox -> UIImageViewサイズ
        point.x = point.x * scale
        
        // y座標を反転
        point.y = ciImageSize.height - point.y
        point.y = point.y * scale
        
        return point
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
