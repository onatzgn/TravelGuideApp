import SwiftUI

struct CustomCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var camera = CameraViewModel()
    
    var body: some View {
        ZStack {
            // 1) Kamera önizlemesi
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                }
                Spacer()
                
                // 3) Alttaki Fotoğraf Çekme Butonu
                Button(action: {
                    camera.takePhoto()
                }) {
                    Image(systemName: "camera.viewfinder")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .padding(30)
                        .background(Color(UIColor.main))
                        .clipShape(Circle())
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Ekrana gelince kamerayı başlat
            camera.startSession()
        }
        .onDisappear {
            // Sayfadan çıkınca durdur
            camera.stopSession()
        }
    }
}
