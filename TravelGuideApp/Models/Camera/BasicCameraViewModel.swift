import AVFoundation
import UIKit

class BasicCameraViewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: currentPosition)
        else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input)   { session.addInput(input) }
            if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        } catch {
            print("Kamera girişi eklenemedi: \(error.localizedDescription)")
        }
    }
    
    func startSession() { if !session.isRunning { session.startRunning() } }
    func stopSession()  { if  session.isRunning { session.stopRunning()  } }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        currentPosition = (currentInput.device.position == .back) ? .front : .back
        
        if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: currentPosition) {
            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                if session.canAddInput(newInput) { session.addInput(newInput) }
            } catch {
                print("Kamera çevirme hatası: \(error.localizedDescription)")
            }
        }
        
        session.commitConfiguration()
    }
}

extension BasicCameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error { print("Çekim hatası: \(error.localizedDescription)"); return }
        guard
            let data  = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        DispatchQueue.main.async {
            self.onPhotoCaptured?(image)
        }
        print("✅ Fotoğraf galeriye kaydedildi – çözünürlük korunuyor.")
    }
}
