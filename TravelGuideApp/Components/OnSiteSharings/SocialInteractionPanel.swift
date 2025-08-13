import SwiftUI

struct SocialInteractionPanel: View {
    var onAddComment: () -> Void
    var onTakePhoto:  () -> Void
    
    var body: some View {
        HStack(spacing: 24) {
            InteractionButton(
                title: "Yorum Yaz",
                systemImage: "text.bubble",
                action: onAddComment
            )
            InteractionButton(
                title: "Fotoğraf Çek",
                systemImage: "camera",
                action: onTakePhoto
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

private struct InteractionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
                    .fontWeight(.bold)
            } icon: {
                Image(systemName: systemImage)
                    .font(.headline)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .overlay(
                Capsule()
                    .stroke(Color(UIColor.main), lineWidth: 2)
            )
        }
        .foregroundColor(.white)
    }
}
