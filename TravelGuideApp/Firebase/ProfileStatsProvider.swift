import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ProfileStatsProvider: ObservableObject {
    @Published var followersCount = 0
    @Published var followingCount = 0

    private var listener: ListenerRegistration?
    private let uid: String

    init(uid: String) {
        self.uid = uid
        start()
    }

    deinit { listener?.remove() }

    private func start() {
        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard
                    let data = snap?.data(),
                    let self = self
                else { return }

                self.followersCount = (data["followers"] as? [String])?.count ?? 0
                self.followingCount = (data["following"] as? [String])?.count ?? 0
            }
    }
}
