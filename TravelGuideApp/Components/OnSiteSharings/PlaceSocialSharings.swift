import SwiftUI

struct SocialShare: Identifiable {
    enum Kind { case comment, photo }
    
    var id:    String
    var userId: String
    var username: String
    var userPhotoURL: String?
    var text:  String? = nil
    var kind:  Kind
    var createdAt: Date
}

struct PlaceSocialSharings: View {
    var shares: [SocialShare]
    var onSelect: (SocialShare) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(shares) { share in
                    ShareBubble(share: share)
                        .onTapGesture {
                            onSelect(share)
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
        }
    }
}

private struct ShareBubble: View {
    let share: SocialShare
    
    private var overlayIcon: String {
        switch share.kind {
        case .comment: return "text.bubble"
        case .photo:   return "camera"
        }
    }
    
    var body: some View {
        VStack(spacing: -10) {
            Image(systemName: overlayIcon)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .padding(6)
                .background(Circle().fill(Color.black.opacity(0.75)))
                .zIndex(1)
            
            ProfileImageView(photoURL: share.userPhotoURL, size: 64)
        }
    }
}
