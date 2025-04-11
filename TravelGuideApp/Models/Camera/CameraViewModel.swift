import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    // Capture session
    var session = AVCaptureSession()
    
    // Önizleme için katman
    var preview: AVCaptureVideoPreviewLayer!
    
    // Fotoğraf çıkışı
    private let photoOutput = AVCapturePhotoOutput()
    
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
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        // Bu data ile UIImage oluşturup kaydedebilirsin:
        let image = UIImage(data: imageData)
        
        // Burada ister galeriye kaydet, ister UIKit/SwiftUI ile paylaş
        print("Fotoğraf çekildi, boyutu: \(imageData.count) byte")
    }
}
