import Foundation
import UIKit
import Vision

class VisionFaceDetection {
    // 顔検出
    func visionFaceDetection(cgInput: CGImage?, ciInput: CIImage, imageView: UIImageView) {
        // リクエストを生成
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            // 処理完了後の処理
            for observation in request.results as! [VNFaceObservation] {
                print("\(observation)")
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
}
