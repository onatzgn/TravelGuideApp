import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    var session = AVCaptureSession()
    
    var preview: AVCaptureVideoPreviewLayer!
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private let classifier = ImageClassifier()
    
    var onClassificationResult: ((String) -> Void)?

    private var currentZoomFactor: CGFloat = 1.0

    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
        } catch {
            print("Kamera aygıtı eklenirken hata: \(error.localizedDescription)")
        }
    }
    
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func saveImage(image: UIImage, fileName: String) {
        let resized = UIGraphicsImageRenderer(size: CGSize(width: 224, height: 224)).image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        }
        
        if let data = resized.jpegData(compressionQuality: 1.0) {
            let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            do {
                try data.write(to: filePath)
                print("Fotoğraf kaydedildi: \(filePath)")
            } catch {
                print("Fotoğraf kaydedilirken hata oluştu: \(error.localizedDescription)")
            }
        }

        UIImageWriteToSavedPhotosAlbum(resized, nil, nil, nil)
        print(" Dönüştürülmüş fotoğraf galeriyi kaydedildi.")
    }

    func setZoom(factor: CGFloat) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        do {
            try device.lockForConfiguration()
            let zoomFactor = min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
            device.videoZoomFactor = zoomFactor
            currentZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Zoom yapılandırılamadı: \(error.localizedDescription)")
        }
    }

    func getZoomFactor() -> CGFloat {
        return currentZoomFactor
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Fotoğraf çekim hatası: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fotoğraf verisi alınamadı")
            return
        }
        guard let image = UIImage(data: imageData) else {
            print("UIImage oluşturulamadı")
            return
        }
        
        let targetSize = CGSize(width: 224, height: 224)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let paddedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        print("Fotoğraf çekildi: \(imageData.count) byte")
        
        self.saveImage(image: image, fileName: "captured_image.jpg")
        
        print("paddedImage boyutu: \(paddedImage.size)")
        
        classifier.classify(image: paddedImage, imageName: "captured_image.jpg") { label, confidence in
            print("\(photo.resolvedSettings.uniqueID): Tahmin = \(label), Güven = \(confidence * 100)%")
            DispatchQueue.main.async {
                self.onClassificationResult?(label)
            }
        }
        
        self.saveImage(image: paddedImage, fileName: "transformed_image.jpg")
        print("Dönüştürülmüş fotoğraf kaydedildi.")
    }
}
