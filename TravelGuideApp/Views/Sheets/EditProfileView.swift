import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthService

    @State private var username: String = ""
    @State private var country: String = ""
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profil Fotoğrafı
                Button {
                    showPicker = true
                } label: {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else if let existing = auth.profileImage {
                        Image(uiImage: existing)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("profilePhoto")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 4)
                .padding(.top, 24)

                // Bilgi Alanları
                IconTextField(icon: "person", placeholder: "Kullanıcı Adı", text: $username, type: .normal)
                IconTextField(icon: "flag", placeholder: "Ülke", text: $country, type: .normal)

                Spacer()
            }
            .padding()
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Geri") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        Task {
                            isSaving = true
                            do {
                                try await auth.updateProfile(
                                    username: username,
                                    country: country,
                                    image: selectedImage
                                )
                                dismiss()
                            } catch {
                                print("Profil güncelleme hatası: \(error.localizedDescription)")
                            }
                            isSaving = false
                        }
                    }
                }
            }
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
            .onAppear {
                if let user = auth.user {
                    username = user.username
                    country = user.country
                }
            }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Kaydediliyor...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}
