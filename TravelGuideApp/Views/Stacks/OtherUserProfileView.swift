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
    @State private var guides: [GuideSummary] = []
    @State private var selectedGuide: GuideSummary? = nil
    @State private var stops: [Stop] = []
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
                    .padding(.top, 50)
                    LandmarkCoinSection(coins: coins)
                        .padding(.top, 24)          // Coin bölümü biraz aşağıda
                    if !guides.isEmpty {
                        Text("Seyahat Rehberleri")
                            .font(.title3.bold())
                            .padding([.horizontal, .top])

                        VStack(spacing: 12) {
                            ForEach(guides) { guide in
                                GuideCardView(guide: guide) {
                                    selectedGuide = guide
                                    stops = []
                                    Task {
                                        stops = await auth.fetchStops(forGuide: guide)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
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
            .sheet(item: $selectedGuide) { guide in
                GuideDetailSheetView(guide: guide, stops: stops)
                    .presentationDetents([.medium, .large])
            }
        }
        .navigationBarBackButtonHidden(false)
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
            guides = await auth.fetchGuidesOfUser(id: user.id, username: user.username, photoURL: user.photoURL)
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
