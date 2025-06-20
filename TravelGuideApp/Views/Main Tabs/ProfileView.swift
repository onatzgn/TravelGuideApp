import SwiftUI
import FirebaseFirestore

enum FollowSheet: Identifiable {
    case followers([TGUser])
    case following([TGUser])

    var id: String {
        switch self {
        case .followers:  return "followers"
        case .following:  return "following"
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthService   // 🔸
    @State private var navigateToSettings = false
    @State private var navigateToAddUser = false
    @State private var followers = 0
    @State private var following = 0
    @State private var activeSheet: FollowSheet?
    @State private var showSavedGuides = false
    @State private var savedGuides: [GuideSummary] = []
    @State private var showCreateGuide = false
    @State private var guides: [GuideSummary] = []
    @State private var selectedGuide: GuideSummary? = nil
    @State private var stops: [Stop] = []
    private func refreshGuides() async {
        guard let uid = auth.user?.id else { return }
        let ownGuides = await auth.fetchGuidesOfUser(
            id: uid,
            username: auth.user?.username ?? "-",
            photoURL: auth.user?.photoURL
        )
        await MainActor.run { guides = ownGuides }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        ProfileHeadPanel(
                            user: auth.user ?? TGUser(id: "", username: "-", country: "-", email: "-", photoURL: nil),
                            isCurrentUser: true,
                            followers: followers,
                            following: following,
                            isFollowed: false,
                            onEdit: { print("Düzenle") },
                            onHamburgerTapped: { navigateToSettings = true },
                            onAddFriendTapped: { navigateToAddUser = true },
                            onFollowersTapped: {
                                Task {
                                    guard let uid = auth.user?.id else { return }
                                    let ids   = await auth.followersIds(of: uid)
                                    let users = await auth.users(for: ids)
                                    await MainActor.run {
                                        activeSheet = .followers(users)
                                    }
                                }
                            },
                            onFollowingTapped: {
                                Task {
                                    guard let uid = auth.user?.id else { return }
                                    let ids   = await auth.followingIds(of: uid)
                                    let users = await auth.users(for: ids)
                                    await MainActor.run {
                                        activeSheet = .following(users)
                                    }
                                }
                            },
                            onSavedTapped: {
                                Task {
                                    let fetched = await auth.fetchSavedGuides()
                                    await MainActor.run {
                                        savedGuides = fetched
                                        showSavedGuides = true
                                    }
                                }
                            }
                        )
                        .padding(.top, 50)
                        LandmarkCoinSection(coins: auth.coins)
                            .padding(.top, 24)
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
                FloatingPlusButton {
                    showCreateGuide = true
                }
                .padding([.trailing, .bottom], 24)
                
                NavigationLink("", destination: SettingsView(), isActive: $navigateToSettings)
                    .opacity(0)
                NavigationLink(destination: AddUserView().environmentObject(auth), isActive: $navigateToAddUser) {
                    EmptyView()
                }
            }
            .navigationTitle("Profil")
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .followers(let users):
                FollowListView(title: "Takipçiler", users: users)
            case .following(let users):
                FollowListView(title: "Takip Edilenler", users: users)
            }
        }
        .sheet(isPresented: $showCreateGuide, onDismiss: {
            Task { await refreshGuides() }
        }) {
            CreateGuideView()
        }
        .sheet(isPresented: $showSavedGuides) {
            SavedGuidesListView(isPresented: $showSavedGuides) { guide in
                selectedGuide = guide
                Task { stops = await auth.fetchStops(forGuide: guide) }
            }
        }
        .sheet(item: $selectedGuide) { guide in
            GuideDetailSheetView(guide: guide, stops: stops)
                .presentationDetents([.medium, .large])
        }
        .task {
            guard let uid = auth.user?.id else { return }
            await refreshGuides()
            followers  = await auth.followersCount(of: uid)
            following  = await auth.followingCount(of: uid)
            let ownGuides = await auth.fetchGuidesOfUser(
                id: auth.user?.id,
                username: auth.user?.username ?? "-",
                photoURL: auth.user?.photoURL
            )
            guides = ownGuides
        }
        .onReceive(auth.$followingIds) { ids in
            following = ids.count
        }
        .onReceive(auth.$followersIds) { ids in
            followers = ids.count
        }
    }
}


#Preview { ProfileView() }
