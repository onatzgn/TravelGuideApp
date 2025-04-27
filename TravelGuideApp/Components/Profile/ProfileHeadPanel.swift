import SwiftUI

/// Alt köşeleri kavisli bir dikdörtgen
struct BottomRoundedRectangle: Shape {
    var radius: CGFloat = 32
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: radius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY - radius),
                          control: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ProfileHeadPanel: View {
    @EnvironmentObject private var auth: AuthService
    @State private var showEditSheet = false

    let user: TGUser
    let isCurrentUser: Bool
    let followers: Int
    let following: Int
    let isFollowed: Bool                // 🔸 yeni
    var onToggleFollow: () -> Void = {}
    var onEdit: () -> Void = {}
    var onFollow: () -> Void = {}
    var onReport: () -> Void = {}
    var onBack: () -> Void = {}
    var onHamburgerTapped: () -> Void = {}
    var onAddFriendTapped: () -> Void = {}
    // Takip listesi aksiyonları
    var onFollowersTapped: () -> Void = {}
    var onFollowingTapped: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // Arka plan
            BottomRoundedRectangle(radius: 36)
                .fill(Color(UIColor.main))
                .frame(height: 220)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)

            // İçerik
            HStack(alignment: .top) {

                // Sol: profil foto
                ZStack(alignment: .bottom) {
                    VStack{
                        ProfileImageView(photoURL: user.photoURL, size: 110)
                    }

                    Text("99")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Capsule().fill(Color.orange)
                                .shadow(radius: 1)
                        )
                        .offset(y: 14)
                }
                .padding(.leading, 24)
                .padding(.trailing, 8)
                .padding(.bottom,90)
                // Orta: isim‑ülke‑düzenle‑takipçi sayıları
                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(user.username)
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)
                        Text(user.country)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    if isCurrentUser {
                        Text("Düzenle")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.black)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                onEdit()
                                showEditSheet = true
                            }
                    } else {
                        // 🔸 Takip düğmesi
                        Text(isFollowed ? "Takip Edildi" : "Takip Et")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isFollowed ? Color.gray : Color.black)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .onTapGesture { onToggleFollow() }
                    }

                    HStack(spacing: 24) {
                        FollowCountButton(title: "Takipçiler",
                                          count: followers,
                                          action: onFollowersTapped)
                        FollowCountButton(title: "Takip Edilenler",
                                          count: following,
                                          action: onFollowingTapped)
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 0)

                // Sağ: ikon sütunu
                if isCurrentUser {
                    VStack(spacing: 18) {
                        IconCircleButton(systemName: "line.3.horizontal", action: onHamburgerTapped)
                        IconCircleButton(systemName: "person.crop.circle.badge.plus", action: onAddFriendTapped)
                        IconCircleButton(systemName: "bookmark")
                    }
                    .padding(.trailing, 20)
                }
            }
            .padding(.top, -20)
            HStack {
                Spacer()
                Button(action: {
                }) {
                    Image("personalMapButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                }
                .padding(.trailing, 52)
                .padding(.bottom, -48)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditProfileView()
                .environmentObject(auth)
        }
    }
}
