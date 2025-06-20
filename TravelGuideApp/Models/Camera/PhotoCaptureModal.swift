import SwiftUI

struct PhotoCaptureModal: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = BasicCameraViewModel()
    
    @State private var capturedImage: UIImage? = nil
    @EnvironmentObject private var auth: AuthService
    let predictedLabel: String
    var body: some View {
        NavigationStack {
            ZStack {
                if let image = capturedImage {
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
                    BasicCameraPreview(camera: camera)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        Button {
                            camera.takePhoto()
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Geri") { dismiss() }
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if capturedImage == nil {
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
                    capturedImage = img        
                    camera.stopSession()
                }
                camera.startSession()
            }
            .onDisappear { camera.stopSession() }
        }
    }
}
