import SwiftUI

/// Fotoğraf çek – ön‑izleme – paylaş akışını yöneten modal sayfa.
/// Sınıflandırma yapılmaz, görsel tam çözünürlükte kaydedilir.
struct PhotoCaptureModal: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = BasicCameraViewModel()
    
    /// Çekilen görsel; nil iken canlı kamera görünür
    @State private var capturedImage: UIImage? = nil
    @EnvironmentObject private var auth: AuthService
    let predictedLabel: String
    var body: some View {
        NavigationStack {
            ZStack {
                if let image = capturedImage {
                    // ---------- ÖN İZLEME ----------
                    Color.black.ignoresSafeArea()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        Button("Paylaş") {
                            if let image = capturedImage {
                                Task {
                                    try? await auth.addPhotoShare(place: predictedLabel, image: image)
                                    dismiss()
                                }
                            }
                        }
                        .font(.headline)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(
                            Capsule().stroke(Color.white, lineWidth: 2)
                        )
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    }
                    
                } else {
                    // ---------- CANLI KAMERA ----------
                    BasicCameraPreview(camera: camera)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        Button {
                            camera.takePhoto()              // Çekim
                        } label: {
                            Image(systemName: "circle.inset.filled")
                                .font(.system(size: 72))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            // Geri butonu – her iki durumda da görünür
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Geri") { dismiss() }
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if capturedImage == nil {           // Yalnızca canlı kamera modunda
                        Button {
                            camera.switchCamera()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                camera.onPhotoCaptured = { img in
                    capturedImage = img          // Ön izlemeye geç
                    camera.stopSession()         // Enerji tasarrufu
                }
                camera.startSession()
            }
            .onDisappear { camera.stopSession() }
        }
    }
}
