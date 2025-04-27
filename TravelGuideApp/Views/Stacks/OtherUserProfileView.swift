import SwiftUI
import FirebaseFirestore

struct OtherUserProfileView: View {
    let user: TGUser
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var isFollowed = false
    @State private var followers  = 0
    @State private var following  = 0
    @State private var coins: [String] = []
    @State private var showFollowers = false
    @State private var showFollowing = false
    @State private var listUsers: [TGUser] = []     // Takip listesi için hazır kullanıcılar
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView {
                VStack(spacing: 0) {
                    ProfileHeadPanel(
                        user: user,
                        isCurrentUser: false,
                        followers: followers,
                        following: following,
                        isFollowed: isFollowed,
                        onToggleFollow: toggleFollow,
                        onReport: { print("Bildirildi") },
                        onBack: { dismiss() },
                        onFollowersTapped: {
                            Task {
                                let ids       = await auth.followersIds(of: user.id ?? "")
                                listUsers     = await auth.users(for: ids)
                                print("Followers →", listUsers.map(\.username))   // DEBUG
                                showFollowers = true
                            }
                        },
                        onFollowingTapped: {
                            Task {
                                let ids        = await auth.followingIds(of: user.id ?? "")
                                listUsers      = await auth.users(for: ids)
                                print("Following →", listUsers.map(\.username))  // DEBUG
                                showFollowing  = true
                            }
                        }
                    )
                    LandmarkCoinSection(coins: coins)
                        .padding(.top, 24)          // Coin bölümü biraz aşağıda
                    Spacer(minLength: 0)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            // Followers Sheet
            .sheet(isPresented: $showFollowers) {
                FollowListView(title: "Takipçiler", users: listUsers)
            }
            // Following Sheet
            .sheet(isPresented: $showFollowing) {
                FollowListView(title: "Takip Edilenler", users: listUsers)
            }

            // Üstteki geri ve bildir butonları
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
                Spacer()
                Button(action: { print("Bildirildi") }) {
                    Image(systemName: "nosign")
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            guard let uid = user.id else { return }
            
            isFollowed     = auth.isFollowing(uid)
            followers      = await auth.followersCount(of: uid)
            following      = await auth.followingCount(of: uid)
            
            // coins
            coins = user.coins
            if coins.isEmpty {
                if let snap = try? await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .getDocument() {
                    coins = snap.data()?["coins"] as? [String] ?? []
                }
            }
        }
    }
    
    // MARK: - Follow / Unfollow
    private func toggleFollow() {
        Task {
            do {
                if isFollowed {
                    try await auth.unfollow(userId: user.id ?? "")
                    followers -= 1
                } else {
                    try await auth.follow(userId: user.id ?? "")
                    followers += 1
                }
                isFollowed.toggle()
            } catch {
                print("Takip hatası: \(error.localizedDescription)")
            }
        }
    }
}
