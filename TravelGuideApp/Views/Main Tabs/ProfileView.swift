
import SwiftUI
import FirebaseFirestore

/// Sheet payload that carries the prepared user list
enum FollowSheet: Identifiable {
    case followers([TGUser])
    case following([TGUser])

    var id: String {            // Identifiable conformance
        switch self {
        case .followers:  return "followers"
        case .following:  return "following"
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthService   // 🔸
    @State private var navigateToSettings = false
    @State private var showAddUserSheet = false
    @State private var followers = 0
    @State private var following = 0
    @State private var activeSheet: FollowSheet?

    var body: some View {
        NavigationView {           // iOS 16+  ➜ NavigationView kullanıyorsan onu bırakabilirsin
            ZStack(alignment: .trailing) {
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
                            onAddFriendTapped: { showAddUserSheet = true },
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
                            }
                        )
                        LandmarkCoinSection(coins: auth.coins)
                            .padding(.top, 24)          // Coin bölümü biraz aşağıda
                            .task {
                                if let uid = auth.user?.id {
                                    do {
                                        try await auth.fetchUser(uid: uid)
                                    } catch {
                                        print("Kullanıcı verisi yenilenemedi: \(error.localizedDescription)")
                                    }
                                }
                            }
                        Spacer(minLength: 0)
                    }
                }
                
                NavigationLink("", destination: SettingsView(), isActive: $navigateToSettings)
                    .opacity(0)
            }
            .navigationTitle("Profil")              // Başlığın boyutu/hizası default
            .toolbarBackground(Color(UIColor.main),
                                for: .navigationBar)
            .toolbarBackground(.visible,
                                for: .navigationBar)
        }
        .sheet(isPresented: $showAddUserSheet) {
            AddUserView()
                .environmentObject(auth)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .followers(let users):
                FollowListView(title: "Takipçiler", users: users)
            case .following(let users):
                FollowListView(title: "Takip Edilenler", users: users)
            }
        }
        .task {
            guard let uid = auth.user?.id else { return }
            // Sayıları
            followers  = await auth.followersCount(of: uid)
            following  = await auth.followingCount(of: uid)
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
/*
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthService   // 🔸
    @State private var navigateToSettings = false
    @State private var showAddUserSheet = false

    var body: some View {
        NavigationView {           // iOS 16+  ➜ NavigationView kullanıyorsan onu bırakabilirsin
            ZStack(alignment: .trailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        ProfileHeadPanel(
                            onHamburgerTapped: { navigateToSettings = true },
                            onAddFriend: { showUserSearch = true }
                        )
                        Text("Profil İçeriği")
                            .padding()
                        Spacer(minLength: 0)
                    }
                }
                .sheet(isPresented: $showAddUserSheet) {
                    AddUserView()
                }
                
                NavigationLink("", destination: SettingsView(), isActive: $navigateToSettings)
                    .opacity(0)
            }
            .navigationTitle("Profil")              // Başlığın boyutu/hizası default
            .toolbarBackground(Color(UIColor.main),
                                for: .navigationBar)
            .toolbarBackground(.visible,
                                for: .navigationBar)
        }
    }
}

#Preview { ProfileView() }
*/
