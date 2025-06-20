import SwiftUI
import PhotosUI  

struct StepTwoView: View {
    @Binding var selectedImage: UIImage?
    let onBack:     () -> Void
    let onComplete: () -> Void
    let onSkip:     () -> Void

    @State private var showPicker = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(Color(UIColor.main))
                }
                Spacer()
            }
            .padding(.horizontal)

            Text("Profil Fotoğrafı Seç")
                .font(.headline)

            Button {
                showPicker = true
            } label: {
                if let ui = selectedImage {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("avatarPlaceholder")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .shadow(radius: 4)

            VStack(spacing: 12) {
                PrimaryButton("Tamamla", showChevron: false) { onComplete() }

                Button("Şimdilik Geç", action: onSkip)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .photosPicker(isPresented: $showPicker,
                      selection: $pickerItem,
                      matching: .images)
        .onChange(of: pickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
}
