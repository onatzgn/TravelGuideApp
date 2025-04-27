import SwiftUI

struct ProfileImageView: View {
    let photoURL: String?
    var size: CGFloat = 96

    var body: some View {
        Group {
            if let urlString = photoURL,
               !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Image("profilePhoto")
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image("profilePhoto")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 5))
        .background(Circle().fill(Color(.systemPink).opacity(0.6)))
    }
}
