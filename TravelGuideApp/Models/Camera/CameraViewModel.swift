import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    // Capture session
    var session = AVCaptureSession()
    
    // Önizleme için katman
    var preview: AVCaptureVideoPreviewLayer!
    
    // Fotoğraf çıkışı
    private let photoOutput = AVCapturePhotoOutput()
    
    private let classifier = ImageClassifier()
    
    var onClassificationResult: ((String) -> Void)?

    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        // Oturum kalitesi
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
    
    // Oturumu başlat
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    // Oturumu durdur
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    // Fotoğraf çek
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // Fotoğrafı kaydetme fonksiyonu
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

        // Galeriye de kaydet
        UIImageWriteToSavedPhotosAlbum(resized, nil, nil, nil)
        print("📸 Dönüştürülmüş fotoğraf galeriyi kaydedildi.")
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    // Fotoğraf çekim tamamlandığında tetiklenir
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
        
        // Görseli modele uygun şekilde 224x224 boyutuna getir
        let targetSize = CGSize(width: 224, height: 224)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1  // Ölçek sabitleniyor
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let paddedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        print("📸 Fotoğraf çekildi: \(imageData.count) byte")
        
        // Fotoğrafı kaydet
        self.saveImage(image: image, fileName: "captured_image.jpg")
        
        // 📏 paddedImage boyutu: \(paddedImage.size)
        print("📏 paddedImage boyutu: \(paddedImage.size)")
        
        // 📷 Fotoğraf adı: captured_image.jpg
        classifier.classify(image: paddedImage, imageName: "captured_image.jpg") { label, confidence in
            print("📷 \(photo.resolvedSettings.uniqueID): Tahmin = \(label), Güven = \(confidence * 100)%")
            DispatchQueue.main.async {
                self.onClassificationResult?(label)
            }
        }
        
        // 2. Dönüşüm işlemi (boyutlandırma vs) fotoğraf kaydettikten sonra
        self.saveImage(image: paddedImage, fileName: "transformed_image.jpg")
        print("Dönüştürülmüş fotoğraf kaydedildi.")
    }
}
