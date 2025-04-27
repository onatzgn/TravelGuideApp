//
//  AuthService.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 19.04.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

struct AppError: Identifiable {
    var id: String { message }
    let message: String
}
// MARK: - Place Comments
extension AuthService {
    // MARK: - Place Photos
    func addPhotoShare(place: String, image: UIImage) async throws {
        guard let me = user else { return }

        // 1. Storage’a yükle
        let imageID = UUID().uuidString
        let imageRef = storage.child("places/\(place)/\(imageID).jpg")
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        _ = try await imageRef.putDataAsync(data)
        let url = try await imageRef.downloadURL()

        // 2. Firestore’a belge ekle
        let docData: [String: Any] = [
            "userId": me.id ?? "",
            "username": me.username,
            "photoURL": me.photoURL ?? NSNull(),
            "imageURL": url.absoluteString,
            "createdAt": Timestamp(date: .now)
        ]

        try await db.collection("places")
            .document(place)
            .collection("photos")
            .addDocument(data: docData)
    }

    func photoShares(for place: String) async -> [SocialShare] {
        guard let meId = user?.id else { return [] }
        let allowed = followingIds + [meId]
        guard !allowed.isEmpty else { return [] }

        var items: [SocialShare] = []
        let chunks = allowed.chunked(into: 10)

        for ch in chunks {
            do {
                let snap = try await db.collection("places")
                    .document(place)
                    .collection("photos")
                    .whereField("userId", in: ch)
                    .getDocuments()

                let part = snap.documents.compactMap { d -> SocialShare? in
                    let data = d.data()
                    return SocialShare(
                        id: d.documentID,
                        userId: data["userId"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        userPhotoURL: data["photoURL"] as? String,
                        text: data["imageURL"] as? String, // imageURL'yi 'text' alanına koyacağız
                        kind: .photo,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
                    )
                }
                items.append(contentsOf: part)
            } catch {
                print("Fotoğraf sorgu hatası: \(error.localizedDescription)")
            }
        }

        items.sort { $0.createdAt > $1.createdAt }
        if let idx = items.firstIndex(where: { $0.userId == meId }) {
            let mine = items.remove(at: idx)
            items.insert(mine, at: 0)
        }
        return items
    }
    /// Yorum ekle
    func addComment(place: String, text: String) async throws {
        guard let me = user else { return }
        
        let data: [String: Any] = [
            "userId"    : me.id ?? "",
            "username"  : me.username,
            "photoURL"  : me.photoURL ?? NSNull(),
            "text"      : text,
            "createdAt" : Timestamp(date: .now)
        ]
        try await db.collection("places")
            .document(place)
            .collection("comments")
            .addDocument(data: data)
    }
    
    /// Takip ettiklerim + kendim → yorum listesi
    func comments(for place: String) async -> [SocialShare] {
        guard let meId = user?.id else { return [] }

        let allowed = followingIds + [meId]
        print("DEBUG allowed ids =", allowed)          // 🐞 takip listesi boş mu?

        guard !allowed.isEmpty else { return [] }

        var items: [SocialShare] = []

        // Firestore “in” filtresi + sıralama => index gerekir.
        // İndeks oluşturmadıysan order-by satırını KALDIR ya da try/catch ile yakala:
        let chunks = allowed.chunked(into: 10)
        for ch in chunks {
            do {
                let q = db.collection("places")
                          .document(place)
                          .collection("comments")
                          .whereField("userId", in: ch)

                // ❌  Index hatasından kaçınmak için geçici olarak yorum satırını kapat
                //     .order(by: "createdAt", descending: true)

                let snap = try await q.getDocuments()

                print("DEBUG chunk \(ch) =>", snap.count, "docs")

                let part = snap.documents.compactMap { d -> SocialShare? in
                    let data = d.data()
                    return SocialShare(
                        id: d.documentID,
                        userId: data["userId"] as? String ?? "",
                        username: data["username"] as? String ?? "",   // <-- Bunu ekle
                        userPhotoURL: data["photoURL"] as? String,
                        text: data["text"] as? String,
                        kind: .comment,
                        createdAt: (data["createdAt"] as? Timestamp)?
                                   .dateValue() ?? .distantPast
                    )
                }
                items.append(contentsOf: part)

            } catch {
                print("Firestore sorgu hatası:", error.localizedDescription)
            }
        }

        // Yerel sıralama (order-by kaldırdıysan)
        items.sort { $0.createdAt > $1.createdAt }

        // Kendi yorumunu ilk sıraya koy
        if let idx = items.firstIndex(where: { $0.userId == meId }) {
            let mine = items.remove(at: idx)
            items.insert(mine, at: 0)
        }
        return items
    }
}
// MARK: - Batch User Fetch
extension AuthService {

    @MainActor
    func users(for ids: [String]) async -> [TGUser] {
        guard !ids.isEmpty else { return [] }

        var result: [TGUser] = []

        // Firestore “in” filtresi en fazla 10 öğe alır
        let chunks = ids.chunked(into: 10)

        for chunk in chunks {
            do {
                let snaps = try await db.collection("users")
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments()

                let chunkUsers = snaps.documents.compactMap { doc in
                    let d = doc.data()
                    return TGUser(
                        id:        doc.documentID,
                        username:  d["username"] as? String ?? "-",
                        country:   d["country"]  as? String ?? "-",
                        email:     d["email"]    as? String ?? "-",
                        photoURL:  d["photoURL"] as? String,
                        coins:     d["coins"]    as? [String] ?? []
                    )
                }
                result.append(contentsOf: chunkUsers)
            } catch {
                print("Takip listesi sorgusu (chunk) hatası: \(error.localizedDescription)")
            }
        }
        return result
    }

    // MARK: - Followers / Following ID helpers
    @MainActor
    func followersIds(of uid: String) async -> [String] {
        (try? await db.collection("users")
               .document(uid)
               .getDocument())?.data()?["followers"] as? [String] ?? []
    }

    @MainActor
    func followingIds(of uid: String) async -> [String] {
        (try? await db.collection("users")
               .document(uid)
               .getDocument())?.data()?["following"] as? [String] ?? []
    }
}

@MainActor
final class AuthService: ObservableObject {

    // MARK: - Singleton
    static let shared = AuthService()
    private init() {}

    // MARK: - Published properties
    @Published var user: TGUser?
    @Published var errorMessage: AppError?
    @Published var profileImage: UIImage?
    @Published var isLoading: Bool = false
    @Published private(set) var followingIds: [String] = []
    @Published private(set) var followersIds: [String] = []
    /// Mekan rozetleri (hatıra paralar)
    @Published private(set) var coins: [String] = []

    private var followingListener: ListenerRegistration?

    private let storage = Storage.storage().reference()

    // MARK: - Register
    func register(username: String,
                  country:  String,
                  email:    String,
                  password: String,
                  image:    UIImage?) async throws {
        isLoading = true
        defer { isLoading = false }
        let authResult = try await Auth.auth().createUser(withEmail: email,
                                                          password: password)
        let uid = authResult.user.uid

        var photoURL: String?
        if let img = image,
           let data = img.jpegData(compressionQuality: 0.8) {
            let ref = storage.child("avatars/\(uid).jpg")
            _ = try await ref.putDataAsync(data)
            photoURL = try await ref.downloadURL().absoluteString
        }

        let userData: [String: Any] = [
            "username":       username,
            "username_lower": username.lowercased(),
            "country":        country,
            "email":          email,
            "photoURL":       photoURL ?? NSNull(),
            "createdAt":      Timestamp(date: Date()),
            "followers":      [],
            "following":      [],
            "coins":         []
        ]
        try await db.collection("users").document(uid).setData(userData)

        // 4) Local model
        let tgUser = TGUser(id: uid,
                            username: username,
                            country:  country,
                            email:    email,
                            photoURL: photoURL,
                            coins:    [])
        self.user = tgUser
        try await preloadProfileImage(from: tgUser.photoURL)
        self.startFollowingListener()
    }

    // MARK: - Login
    func login(email: String, password: String) async throws {
        do {
            isLoading = true
            defer { isLoading = false }
            let result = try await Auth.auth().signIn(withEmail: email,
                                                      password: password)
            try await fetchUser(uid: result.user.uid)
            try await preloadProfileImage(from: self.user?.photoURL)
            self.startFollowingListener()
        } catch {
            self.errorMessage = AppError(message: "Giriş başarısız: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Fetch
    func fetchUser(uid: String) async throws {
        let snap = try await db.collection("users").document(uid).getDocument()
        guard let data = snap.data() else { return }

        let tgUser = TGUser(
            id:        uid,
            username:  data["username"] as? String ?? "",
            country:   data["country"]  as? String ?? "",
            email:     data["email"]    as? String ?? "",
            photoURL:  data["photoURL"] as? String,
            coins:     data["coins"]    as? [String] ?? []
        )
        self.user = tgUser
        self.coins = tgUser.coins
    }

    // MARK: - Logout
    func signOut() throws {
        try Auth.auth().signOut()
        stopListeners()
        self.user = nil
    }
    
    // MARK: - Session Restore
    func restoreSession() async {
        if let user = Auth.auth().currentUser {
            do {
                try await fetchUser(uid: user.uid)
                try await preloadProfileImage(from: self.user?.photoURL)
                self.startFollowingListener()
            } catch {
                self.errorMessage = AppError(message: "Oturum geri yüklenemedi: \(error.localizedDescription)")
                self.user = nil
            }
        }
    }
    
    // MARK: - Preload Profile Image
    private func preloadProfileImage(from urlString: String?) async {
        guard let urlString = urlString,
              let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.profileImage = UIImage(data: data)
        } catch {
            print("Profil resmi indirilemedi: \(error.localizedDescription)")
        }
    }

    // MARK: - Search Users
    // Nickname ile users içinde arama
    @MainActor
    func searchUsers(nickname: String) async -> [TGUser] {
        do {
            let snapshot = try await db.collection("users")
                .whereField("username", isGreaterThanOrEqualTo: nickname)
                .whereField("username", isLessThanOrEqualTo: nickname + "\u{f8ff}")
                .getDocuments()

            return snapshot.documents.compactMap { doc in
                let data = doc.data()
                return TGUser(
                    id:        doc.documentID,
                    username:  data["username"] as? String ?? "-",
                    country:   data["country"]  as? String ?? "-",
                    email:     data["email"]    as? String ?? "-",
                    photoURL:  data["photoURL"] as? String,
                    coins:     data["coins"]    as? [String] ?? []
                )
            }
        } catch {
            print("Arama hatası: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(username: String,
                       country: String,
                       image: UIImage?) async throws {
        guard let uid = user?.id else { return }
        
        isLoading = true
        defer { isLoading = false }

        var updatedPhotoURL = user?.photoURL

        // 1. Yeni fotoğraf varsa storage’a yükle
        if let image = image,
           let data = image.jpegData(compressionQuality: 0.8) {
            let ref = storage.child("avatars/\(uid).jpg")
            _ = try await ref.putDataAsync(data)
            updatedPhotoURL = try await ref.downloadURL().absoluteString
        }

        // 2. Firestore güncelle
        let updateData: [String: Any] = [
            "username":       username,
            "username_lower": username.lowercased(),
            "country":        country,
            "photoURL":       updatedPhotoURL ?? NSNull()
        ]
        try await db.collection("users").document(uid).updateData(updateData)

        // 3. Local user modelini güncelle
        let updatedUser = TGUser(id: uid,
                                 username: username,
                                 country:  country,
                                 email:    self.user?.email ?? "",
                                 photoURL: updatedPhotoURL)
        self.user = updatedUser
        try await preloadProfileImage(from: updatedPhotoURL)
    }
    
    // MARK: - Coins
    /// Kullanıcının koleksiyonuna yeni bir hatıra para etiketi ekler.
    func addCoin(_ label: String) async {
        guard let uid = user?.id else { return }
        do {
            try await db.collection("users")
                .document(uid)
                .updateData([
                    "coins": FieldValue.arrayUnion([label])
                ])
            if !coins.contains(label) {
                coins.append(label)
            }
        } catch {
            print("Coin eklenemedi: \(error.localizedDescription)")
        }
    }

    // MARK: - Follow / Unfollow
    func follow(userId targetUid: String) async throws {
        guard let currentUid = user?.id, currentUid != targetUid else { return }

        let batch  = db.batch()
        let meRef  = db.collection("users").document(currentUid)
        let himRef = db.collection("users").document(targetUid)

        batch.updateData([
            "following": FieldValue.arrayUnion([targetUid])
        ], forDocument: meRef)

        batch.updateData([
            "followers": FieldValue.arrayUnion([currentUid])
        ], forDocument: himRef)

        try await batch.commit()
    }

    func unfollow(userId targetUid: String) async throws {
        guard let currentUid = user?.id, currentUid != targetUid else { return }

        let batch  = db.batch()
        let meRef  = db.collection("users").document(currentUid)
        let himRef = db.collection("users").document(targetUid)

        batch.updateData([
            "following": FieldValue.arrayRemove([targetUid])
        ], forDocument: meRef)

        batch.updateData([
            "followers": FieldValue.arrayRemove([currentUid])
        ], forDocument: himRef)

        try await batch.commit()
    }
    
    func startFollowingListener() {
        guard let uid = user?.id else { return }

        followingListener?.remove()
        followingListener = db.collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let data = snap?.data(),
                      let ids  = data["following"] as? [String] else { return }
                self?.followingIds = ids
                if let flw = data["followers"] as? [String] {
                    self?.followersIds = flw
                }
            }
    }
    
    func stopListeners() {
        followingListener?.remove()
        followingListener = nil
        followingIds = []
        followersIds = []
    }
    
    func isFollowing(_ uid: String) -> Bool {
        followingIds.contains(uid)
    }

    func followersCount(of uid: String) async -> Int {
        let doc = try? await db.collection("users").document(uid).getDocument()
        return (doc?.data()?["followers"] as? [String])?.count ?? 0
    }

    func followingCount(of uid: String) async -> Int {
        let doc = try? await db.collection("users").document(uid).getDocument()
        return (doc?.data()?["following"] as? [String])?.count ?? 0
    }
}

// MARK: - TGUser modeli
struct TGUser: Identifiable {
    var id: String?
    var username: String
    var country:  String
    var email:    String
    var photoURL: String?
    var coins:    [String] = []
}
