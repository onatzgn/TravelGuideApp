import SwiftUI

struct FeedSectionView: View {
    // later you’ll bind this to a @State or @Observed data source
    private var items: [FeedItem] = []

    var body: some View {
        Text("Akış")
            .font(.title3.bold())
            .padding(.bottom, 4)

        if items.isEmpty {
            // empty-state placeholder
            VStack(spacing: 4) {
                Image(systemName: "tray")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Henüz gösterilecek bir etkinlik yok.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 220)
        } else {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    FeedItemView(item: item)
                }
            }
        }
    }
}

/// Stand-in model you’ll replace later
struct FeedItem: Identifiable {
    let id = UUID()
    let username: String
    let text: String
    let isFollowRequest: Bool
}

/// One row – style matches the mock
struct FeedItemView: View {
    let item: FeedItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AvatarView(url: nil, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.username).fontWeight(.semibold)
                Text(item.text).foregroundColor(.secondary)
            }
            Spacer()
            if item.isFollowRequest {
                Button("Takip Et") { /* TODO */ }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().stroke(Color.accentColor, lineWidth: 1.5)
                    )
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        )
    }
}
