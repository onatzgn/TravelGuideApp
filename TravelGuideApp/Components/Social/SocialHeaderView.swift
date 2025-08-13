import SwiftUI

/// Shows:  avatar + username   |   (friend) (dm)
struct SocialHeaderView: View {
    var user: TGUser
    var friendsBadge: Int? = nil
    var messagesBadge: Int? = nil

    @EnvironmentObject private var auth: AuthService
    @State private var navigateToAddUser = false

    var body: some View {
        HStack(spacing: 12) {
            // Avatar + username … tap ➜ Profile
            NavigationLink {
                ProfileView()
                    .environmentObject(auth) // forward env-obj
            } label: {
                HStack(spacing: 8) {
                    // AvatarView(url: user.photoURL, size: 36)  ❌
                    AvatarView(url: URL(string: user.photoURL ?? ""),   // ✅ String? → URL?
                               size: 36)
                    Text(user.username)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            Spacer()

            // Icons (placeholders for now)
            BadgeIconButton(systemImage: "person.badge.plus",
                            badge: friendsBadge) {
                navigateToAddUser = true
            }
            BadgeIconButton(systemImage: "bubble.left",
                            badge: messagesBadge) {
                // TODO: open DM list
            }
        }
        .padding(.vertical, 8)
        .background(
            NavigationLink(
                destination: AddUserView().environmentObject(auth),
                isActive: $navigateToAddUser
            ) { EmptyView() }
            .hidden()
        )
    }
}
