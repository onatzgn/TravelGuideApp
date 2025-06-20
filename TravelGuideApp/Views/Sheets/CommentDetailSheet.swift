import SwiftUI

struct CommentDetailSheet: View {
    let share: SocialShare

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ProfileImageView(photoURL: share.userPhotoURL, size: 56)
                Text(share.username)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top) 

            if let text = share.text {
                Text(text)
                    .font(.body)
                    .padding()
            } else {
                Text("Fotoğraf paylaşımı (şimdilik görüntülenmiyor)")
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()
        }
        .presentationDetents([.medium])
    }
}
