import SwiftUI

struct FollowListView: View {
    let title: String
    let users: [TGUser]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedUser: TGUser? = nil

    var body: some View {
        NavigationStack {
            List(users) { user in
                Button {
                    selectedUser = user
                } label: {
                    HStack {
                        ProfileImageView(photoURL: user.photoURL, size: 44)
                        VStack(alignment: .leading) {
                            Text(user.username).font(.headline)
                            Text(user.country).font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .overlay {
                if users.isEmpty {
                    Text("Henüz kimse yok")
                        .foregroundColor(.secondary)
                }
            }
            .navigationDestination(item: $selectedUser) { user in
                OtherUserProfileView(user: user)
            }
        }
    }
}
