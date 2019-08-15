import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!

    var session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        // カメラ設定
        setting()
        // プレビュー
        setPreview()
        // セッション開始
        session.startRunning()
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
    }
    
    // プレビューの設定
    func setPreview() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.masksToBounds = true
        cameraView.layer.addSublayer(previewLayer)
    }
    
    @IBAction func changeCamera(_ sender: UIButton) {
    }
    

}
