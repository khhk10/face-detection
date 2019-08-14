import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var session = AVCaptureSession()
    
    @IBOutlet weak var cameraView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // カメラ設定
        setting()
    }
    
    // カメラの設定
    func setting() {
        session.beginConfiguration() // 設定開始
        // デバイス
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        // 入力
        guard
            let videoInput = try? AVCaptureDeviceInput(device: device!),
            session.canAddInput(videoInput)
            else { return }
        session.addInput(videoInput)
        // 出力
        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(photoOutput) else { return }
        // session.sessionPreset = .photo
        session.addOutput(photoOutput)
        session.commitConfiguration() // 設定更新
        
        // プレビュー
        
    }

}
