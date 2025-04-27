/*
import SwiftUI
import FirebaseFirestore

struct UserSearchView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var results: [TGUser] = []
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            List {
                ForEach(results) { user in
                    UserSearchRow(user: user)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Kullanıcı Ara")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .searchable(text: $searchText, prompt: "Kullanıcı adı")
            .onChange(of: searchText) { _ in performSearch() }
        }
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        let text = searchText.lowercased()
        // prefix arama için u+{f8ff} hilesi
        let endText = text + "\u{f8ff}"
        Task {
            do {
                let snap = try await db
                    .collection("users")
                    .whereField("username_lower", isGreaterThanOrEqualTo: text)
                    .whereField("username_lower", isLessThanOrEqualTo: endText)
                    .getDocuments()
                let users = snap.documents.compactMap { doc -> TGUser? in
                    let data = doc.data()
                    guard let uname = data["username"] as? String,
                          let country = data["country"] as? String else {
                        return nil
                    }
                    return TGUser(
                        id: doc.documentID,
                        username: uname,
                        country: country,
                        email: data["email"] as? String ?? "",
                        photoURL: data["photoURL"] as? String
                    )
                }
                await MainActor.run { results = users }
            } catch {
                print("Arama hata:", error)
            }
        }
    }
}
*/
