import SwiftUI

struct SocialView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // ── Top Bar ────────────────────────────────
                SocialHeaderView(
                    user: auth.user ?? TGUser.mock,
                    friendsBadge: 0,
                    messagesBadge: 9
                )

                // ── Feed Section (empty for now) ──────────
                FeedSectionView()

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("Sosyal")
        }
    }
}
