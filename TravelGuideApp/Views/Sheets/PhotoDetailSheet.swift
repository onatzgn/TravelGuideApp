import SwiftUI

struct PhotoDetailSheet: View {
    let share: SocialShare
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ProfileImageView(photoURL: share.userPhotoURL, size: 56)
                Text(share.username)
                    .font(.headline)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal)

            if let imageUrl = share.text, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                            .padding()
                    case .failure:
                        Text("Fotoğraf yüklenemedi")
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("Geçerli bir görsel bağlantısı bulunamadı")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .presentationDetents([.medium])
    }
}
