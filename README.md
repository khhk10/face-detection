# face-detection

Introduction to face detection 

## 1. CIDetector - CIDetectorTypeFace
CIFaceFeature
- face bounds
- left and right eye positions
- mouth position

Left: high accuracy,  Right: low accuracy

<img src="https://github.com/khhk10/face-detection/blob/master/images/lena_high.png" height="220"> <img src="https://github.com/khhk10/face-detection/blob/master/images/lena_low.png" height="220">

## 2. Vision framework
VNFaceObservation
- bounding box
- landmarks
  - eyes, eyebrows, nose, inner and outer lips, face contour

<img src="https://github.com/khhk10/face-detection/blob/master/images/lena_landmarks.png" height="220">

## reference

- [Core Image - CIDetector](https://developer.apple.com/documentation/coreimage/cidetector)
- [Face Detection Tutorial Using the Vision Framework for iOS](https://www.raywenderlich.com/1163620-face-detection-tutorial-using-the-vision-framework-for-ios)
- [iOS 11 画像解析フレームワークVisionで顔認識を試した結果](https://dev.classmethod.jp/smartphone/iphone/ios-11-vision/)
- [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images)
