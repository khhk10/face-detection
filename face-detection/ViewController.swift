import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inputImage = UIImage(named: "nasa.jpg")!
        print("lena size : \(inputImage.size)")
        imageView.image = inputImage
        print("imageView size : \(imageView.bounds.size)")
        print("imageView.image : \(imageView.image!.size)")
        imageView.contentMode = .scaleToFill
        let ciInput = CIImage(image: inputImage)!
        
        // 顔検出
        let ciFaceDetection = CIFaceDetection()
        ciFaceDetection.detectFace(ciInput: ciInput, imageView: imageView)
    }
}
