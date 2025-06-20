import SwiftUI

struct AddUserView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var results: [TGUser] = []
    @State private var selectedUser: TGUser? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(results) { user in
                    NavigationLink(destination: OtherUserProfileView(user: user)) {
                        HStack {
                            Group {
                                if let urlString = user.photoURL,
                                   let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 48, height: 48)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                        case .failure:
                                            Image("profilePhoto")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image("profilePhoto")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.trailing, 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.username)
                                    .font(.headline)
                                Text(user.country)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Kullanıcı adı")
            .onChange(of: searchText) { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    results = []
                } else {
                    Task {
                        let fetched = await auth.searchUsers(nickname: trimmed)
                        await MainActor.run {
                            results = fetched
                        }
                    }
                }
            }
            .navigationTitle("Arkadaş Ekle")
        }
    }
}
