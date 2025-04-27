import SwiftUI
import AVFoundation

struct BasicCameraPreview: UIViewRepresentable {
    @ObservedObject var camera: BasicCameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.previewLayer.frame = view.frame
        camera.previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.previewLayer)
        camera.startSession()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
