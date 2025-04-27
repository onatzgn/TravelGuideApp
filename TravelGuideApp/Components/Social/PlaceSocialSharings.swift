import SwiftUI

/// Örnek veri modeli (istersen Firestore’dan doldur)
struct SocialShare: Identifiable {
    enum Kind { case comment, photo }
    
    var id:    String            // Firestore belge ID’si
    var userId: String
    var username: String     // <-- Burası yeni
    var userPhotoURL: String?
    var text:  String? = nil     // ⬅️ yorum içeriği
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
                            onSelect(share) // 👈🏻 Tıklanınca iletişim kur
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
    
    /// Hangi ikon gösterilecek?
    private var overlayIcon: String {
        switch share.kind {
        case .comment: return "text.bubble"
        case .photo:   return "camera"
        }
    }
    
    var body: some View {
        VStack(spacing: -10) {               //  Negatif spacing → üst üste binerler
            // Balon – şapkanın üstünde
            Image(systemName: overlayIcon)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .padding(6)
                .background(Circle().fill(Color.black.opacity(0.75)))
                .zIndex(1)                   //  Profil fotoğrafından önde dursun
            
            // Profil fotoğrafı
            ProfileImageView(photoURL: share.userPhotoURL, size: 64)
        }
    }
}
