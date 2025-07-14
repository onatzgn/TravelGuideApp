// MARK: - Guide Summary Model
struct GuideSummary: Identifiable {
    let id: String
    let title: String
    let description: String
    let coverURL: String
    let username: String
    let userPhotoURL: String?
    let city: String
}

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
import CoreLocation
import MapKit
import FirebaseAnalytics

struct AppError: Identifiable {
    var id: String { message }
    let message: String
}
extension AuthService {
    func printFirebaseToken() {
        guard let user = Auth.auth().currentUser else {
            print("Henüz oturum açılmadı, token yok.")
            return
        }

        user.getIDToken { token, error in
            if let error = error {
                print("Token alınamadı: \(error.localizedDescription)")
                return
            }
            if let token = token {
                print(" Firebase ID Token: \(token)")
            }
        }
    }
    // MARK: - Place Photos
    func addPhotoShare(place: String, image: UIImage) async throws {
        let tracer = PerformanceTracer(name: "addPhotoShare_trace")
        do {
            guard let me = user else { return }

            // Ensure place is not empty (after trimming whitespace/newlines)
            guard !place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                print("⚠️ place parametresi boş veya sadece boşluk içeriyor")
                return
            }

            // 1. storage’a yükleme
            let imageID = UUID().uuidString
            let imageRef = storage.child("places/\(place)/\(imageID).jpg")
            guard let data = image.jpegData(compressionQuality: 0.8) else { return }
            _ = try await imageRef.putDataAsync(data)
            let url = try await imageRef.downloadURL()

            // 2. firestore’a belge ekleme
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
            Analytics.logEvent("photo_shared", parameters: [
                "place": place
            ])
            tracer.stop()
        } catch {
            CrashReporter.log("⚠️ Fotoğraf paylaşımı sırasında hata oluştu")
            CrashReporter.record(error, context: "addPhotoShare place=\\(place)")
            throw error
        }
    }

    func photoShares(for place: String) async -> [SocialShare] {
        guard let meId = user?.id else { return [] }
        guard !place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ place parametresi boş veya sadece boşluk içeriyor")
            return []
        }
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
                        text: data["imageURL"] as? String,
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
    // MARK: - Guide Paylaşımı (şehir bazlı)
    func shareGuide(city: String,
                    title: String,
                    description: String,
                    coverImage: UIImage,
                    stops: [Stop]) async throws {
        guard let me = user else { return }
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ city parametresi boş veya sadece boşluk içeriyor")
            return
        }

        let tracer = PerformanceTracer(name: "shareGuide_trace")

        do {
            do {
                // cover görselini Storage'a yükleme
                let guideId  = UUID().uuidString
                let imageRef = storage.child("guides/\(city)/\(guideId)/cover.jpg")
                guard let imageData = coverImage.jpegData(compressionQuality: 0.8) else { return }
                _ = try await imageRef.putDataAsync(imageData)
                let imageURL = try await imageRef.downloadURL()

                // durak verilerini JSON hâline getirme
                let stopsData: [[String: Any]] = stops.map { stop in
                    [
                        "order"     : stop.order,
                        "placeName" : stop.place?.name ?? "",
                        "latitude"  : stop.place?.placemark.coordinate.latitude ?? 0,
                        "longitude" : stop.place?.placemark.coordinate.longitude ?? 0,
                        "categories": stop.categories.map { $0.title },
                        "note"      : stop.note
                    ]
                }

                // firestore'a rehber verisini ekle
                let guideData: [String: Any] = [
                    "userId"     : me.id ?? "",
                    "username"   : me.username,
                    "photoURL"   : me.photoURL ?? NSNull(),
                    "city"       : city,
                    "title"      : title,
                    "description": description,
                    "coverURL"   : imageURL.absoluteString,
                    "stops"      : stopsData,
                    "createdAt"  : Timestamp(date: Date())
                ]

                try await db.collection("guides")
                    .document(city)
                    .collection("items")
                    .document(guideId)
                    .setData(guideData)

                // aynı rehberi kullanıcının guides alt koleksiyonuna kaydetme
                let userGuideRef = db.collection("users")
                                     .document(me.id ?? "")
                                     .collection("guides")
                                     .document(guideId)

                try await userGuideRef.setData([
                    "city"       : city,
                    "title"      : title,
                    "description": description,
                    "coverURL"   : imageURL.absoluteString,
                    "createdAt"  : Timestamp(date: Date())
                ])
                Analytics.logEvent("guide_shared", parameters: [
                    "city": city,
                    "stop_count": stops.count
                ])
                tracer.stop()
            } catch {
                CrashReporter.log("⚠️ Rehber paylaşımı sırasında hata oluştu")
                CrashReporter.record(error, context: "shareGuide city=\\(city)")
                throw error
            }
        }
    }

    // MARK: - Guide Listeleme
    func fetchGuides(for city: String) async -> [GuideSummary] {
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ city parametresi boş veya sadece boşluk içeriyor")
            return []
        }
        let tracer = PerformanceTracer(name: "fetchGuides_trace")
        do {
            let snapshot = try await db.collection("guides")
                .document(city.lowercased())
                .collection("items")
                .getDocuments()

            let items = snapshot.documents.compactMap { doc -> GuideSummary? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let coverURL = data["coverURL"] as? String,
                      let username = data["username"] as? String,
                      let city = data["city"] as? String else { return nil }

                let photoURL = data["photoURL"] as? String

                return GuideSummary(
                    id: doc.documentID,
                    title: title,
                    description: description,
                    coverURL: coverURL,
                    username: username,
                    userPhotoURL: photoURL,
                    city: city
                )
            }

            Analytics.logEvent("guides_fetched", parameters: [
                "city": city
            ])
            tracer.stop()
            return items
        } catch {
            print("Guideler çekilemedi: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - guide Duraklarını Getirme
    func fetchStops(forGuide guide: GuideSummary) async -> [Stop] {
        guard !guide.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !guide.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ guide.city veya guide.id boş veya sadece boşluk içeriyor")
            return []
        }
        let tracer = PerformanceTracer(name: "fetchStops_trace")
        do {
            let doc = try await db.collection("guides")
                .document(guide.city.lowercased())
                .collection("items")
                .document(guide.id)
                .getDocument()

            guard let data = doc.data(),
                  let stopsData = data["stops"] as? [[String: Any]] else { tracer.stop(); return [] }

            let stops = stopsData.enumerated().map { (idx, dict) in
                let categories = (dict["categories"] as? [String] ?? []).compactMap { title in
                    Stop.Category.allCases.first { $0.title == title }
                }

                let coord = CLLocationCoordinate2D(
                    latitude: dict["latitude"] as? CLLocationDegrees ?? 0,
                    longitude: dict["longitude"] as? CLLocationDegrees ?? 0
                )

                let placemark = MKPlacemark(coordinate: coord)
                let item = MKMapItem(placemark: placemark)
                item.name = dict["placeName"] as? String

                return Stop(
                    order: dict["order"] as? Int ?? idx + 1,
                    place: item,
                    categories: Set(categories),
                    note: dict["note"] as? String ?? ""
                )
            }
            Analytics.logEvent("stops_fetched", parameters: [
                "guide_id": guide.id,
                "city": guide.city
            ])
            tracer.stop()
            return stops
        } catch {
            CrashReporter.log("⚠️ Duraklar alınırken hata oluştu")
            CrashReporter.record(error, context: "fetchStops guide=\\(guide.id)")
            print("Duraklar alınamadı: \(error)")
            return []
        }
    }
    
    // MARK: - Kullanıcının Rehberleri
    func fetchGuidesOfUser(id: String?, username: String, photoURL: String?) async -> [GuideSummary] {
        let tracer = PerformanceTracer(name: "fetchGuidesOfUser_trace")
        guard let uid = id else { return [] }
        do {
            let snap = try await db.collection("users")
                .document(uid)
                .collection("guides")
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let guides: [GuideSummary] = snap.documents.compactMap { doc in
                let d = doc.data()
                guard let title = d["title"] as? String,
                      let descr = d["description"] as? String,
                      let cover = d["coverURL"] as? String,
                      let city  = d["city"] as? String else { return nil }

                return GuideSummary(
                    id: doc.documentID,
                    title: title,
                    description: descr,
                    coverURL: cover,
                    username: username,
                    userPhotoURL: photoURL,
                    city: city
                )
            }
            Analytics.logEvent("user_guides_fetched", parameters: [
                "user_id": id ?? "nil"
            ])
            tracer.stop()
            return guides
        } catch {
            CrashReporter.log("⚠️ Profil rehberleri alınamadı")
            CrashReporter.record(error, context: "fetchGuidesOfUser id=\\(id ?? \"nil\")")
            print("Profil rehberleri alınamadı:", error.localizedDescription)
            return []
        }
    }
    // Yorum ekleme
    func addComment(place: String, text: String) async throws {
        guard !place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ place parametresi boş veya sadece boşluk içeriyor")
            return
        }
        do {
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
        } catch {
            CrashReporter.log("⚠️ Yorum eklenemedi")
            CrashReporter.record(error, context: "addComment place=\\(place)")
            throw error
        }
    }
    
    // Takip ettiklerim + kendim → yorum listesi
    func comments(for place: String) async -> [SocialShare] {
        guard !place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ place parametresi boş veya sadece boşluk içeriyor")
            return []
        }
        guard let meId = user?.id else { return [] }

        let allowed = followingIds + [meId]
        print("DEBUG allowed ids =", allowed)

        guard !allowed.isEmpty else { return [] }

        var items: [SocialShare] = []

        // firestore “in” filtresi + sıralama => index
        let chunks = allowed.chunked(into: 10)
        for ch in chunks {
            do {
                let q = db.collection("places")
                          .document(place)
                          .collection("comments")
                          .whereField("userId", in: ch)
                //     .order(by: "createdAt", descending: true)

                let snap = try await q.getDocuments()

                print("DEBUG chunk \(ch) =>", snap.count, "docs")

                let part = snap.documents.compactMap { d -> SocialShare? in
                    let data = d.data()
                    return SocialShare(
                        id: d.documentID,
                        userId: data["userId"] as? String ?? "",
                        username: data["username"] as? String ?? "",
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

        items.sort { $0.createdAt > $1.createdAt }

        // kendi yorumumuz ilk sıraya
        if let idx = items.firstIndex(where: { $0.userId == meId }) {
            let mine = items.remove(at: idx)
            items.insert(mine, at: 0)
        }
        return items
    }
    
    // MARK: - Guide Likes

    //unlike guide
    func unlikeGuide(guide: GuideSummary, by userId: String) async {
        guard !guide.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !guide.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ guide.city veya guide.id boş veya sadece boşluk içeriyor")
            return
        }
        let ref = db.collection("guides")
            .document(guide.city.lowercased())
            .collection("items")
            .document(guide.id)
            .collection("likes")
            .document(userId)

        do {
            try await ref.delete()
        } catch {
            print("Beğeni kaldırılamadı: \(error.localizedDescription)")
        }
    }

    //check if the current user has liked a guide
    func hasLikedGuide(_ guide: GuideSummary) async -> Bool {
        guard !guide.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !guide.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ guide.city veya guide.id boş veya sadece boşluk içeriyor")
            return false
        }
        guard let userId = user?.id else { return false }

        let doc = try? await db.collection("guides")
            .document(guide.city.lowercased())
            .collection("items")
            .document(guide.id)
            .collection("likes")
            .document(userId)
            .getDocument()
        return doc?.exists == true
    }

    //get like count for a guide
    func fetchLikeCount(for guide: GuideSummary) async -> Int {
        guard !guide.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !guide.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ guide.city veya guide.id boş veya sadece boşluk içeriyor")
            return 0
        }
        let snap = try? await db.collection("guides")
            .document(guide.city.lowercased())
            .collection("items")
            .document(guide.id)
            .collection("likes")
            .getDocuments()
        return snap?.count ?? 0
    }

    //like a guide
    func likeGuide(guide: GuideSummary, by userId: String) async {
        guard !guide.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !guide.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ guide.city veya guide.id boş veya sadece boşluk içeriyor")
            return
        }
        let ref = db.collection("guides")
            .document(guide.city.lowercased())
            .collection("items")
            .document(guide.id)
            .collection("likes")
            .document(userId)

        do {
            try await ref.setData(["likedAt": Timestamp(date: Date())])
        } catch {
            print("Beğeni eklenemedi: \(error.localizedDescription)")
        }
    }
}
// MARK: - Batch User Fetch
extension AuthService {

    @MainActor
    func users(for ids: [String]) async -> [TGUser] {
        guard !ids.isEmpty else { return [] }

        var result: [TGUser] = []

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

    // MARK: - followers / following id helpers
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

    static let shared = AuthService()
    private init() {}

    @Published var user: TGUser?
    @Published var errorMessage: AppError?
    @Published var profileImage: UIImage?
    @Published var isLoading: Bool = false
    @Published private(set) var followingIds: [String] = []
    @Published private(set) var followersIds: [String] = []
    @Published private(set) var coins: [String] = []

    private var followingListener: ListenerRegistration?

    private let storage = Storage.storage().reference()

    // MARK: - register kısmı
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

        // local model
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

    // MARK: - kogin kısmı
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

    // MARK: - fetch
    func fetchUser(uid: String) async throws {
        let snap = try await db.collection("users").document(uid).getDocument()
        guard let data = snap.data() else { return }

        let tgUser = TGUser(
            id:        uid,
            username:  data["username"] as? String ?? "",
            country:   data["country"]  as? String ?? "",
            email:     data["email"]    as? String ?? "",
            photoURL:  data["photoURL"] as? String,
            coins:     data["coins"]    as? [String] ?? [],
            savedGuides: data["savedGuides"] as? [String] ?? []
        )
        self.user = tgUser
        self.coins = tgUser.coins
    }

    // MARK: - logout
    func signOut() throws {
        try Auth.auth().signOut()
        stopListeners()
        self.user = nil
    }
    
    // MARK: - session restore
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
    
    // MARK: - preload the profile image
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

    // MARK: - search users
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
    
    // MARK: - update profil
    func updateProfile(username: String,
                       country: String,
                       image: UIImage?) async throws {
        guard let uid = user?.id else { return }
        
        isLoading = true
        defer { isLoading = false }

        var updatedPhotoURL = user?.photoURL

        // yeni fotoğraf varsa storage’a yüklemece
        if let image = image,
           let data = image.jpegData(compressionQuality: 0.8) {
            let ref = storage.child("avatars/\(uid).jpg")
            _ = try await ref.putDataAsync(data)
            updatedPhotoURL = try await ref.downloadURL().absoluteString
        }

        // firestore u güncelle
        let updateData: [String: Any] = [
            "username":       username,
            "username_lower": username.lowercased(),
            "country":        country,
            "photoURL":       updatedPhotoURL ?? NSNull()
        ]
        try await db.collection("users").document(uid).updateData(updateData)

        // local user modelini güncelle
        let updatedUser = TGUser(id: uid,
                                 username: username,
                                 country:  country,
                                 email:    self.user?.email ?? "",
                                 photoURL: updatedPhotoURL)
        self.user = updatedUser
        try await preloadProfileImage(from: updatedPhotoURL)
    }
    
    // MARK: - coins
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

    // MARK: - follow ve unnfollow
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
struct TGUser: Identifiable, Hashable {
    var id: String?
    var username: String
    var country:  String
    var email:    String
    var photoURL: String?
    var coins:    [String] = []
    var savedGuides: [String] = []

    static func == (lhs: TGUser, rhs: TGUser) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - guide kaydetme
extension AuthService {

    func saveGuide(_ guide: GuideSummary) async {
        guard let uid = user?.id else { return }

        let entry: [String: Any] = [
            "id"  : guide.id,
            "city": guide.city.lowercased()
        ]
        try? await db.collection("users")
            .document(uid)
            .updateData([
                "savedGuides": FieldValue.arrayUnion([entry])
            ])
    }

    func unsaveGuide(_ guide: GuideSummary) async {
        guard let uid = user?.id else { return }
        let ref = db.collection("users").document(uid)

        let mapEntry: [String: Any] = ["id": guide.id,
                                       "city": guide.city.lowercased()]
        let strEntry = guide.id


        try? await ref.updateData([
            "savedGuides": FieldValue.arrayRemove([mapEntry, strEntry])
        ])
    }

    // check if the user has saved a given guide
    func hasSavedGuide(_ guide: GuideSummary) async -> Bool {
        guard let uid = user?.id else { return false }

        let doc = try? await db.collection("users").document(uid).getDocument()
        let raw = doc?.data()?["savedGuides"] as? [Any] ?? []

        for item in raw {
            if let idStr = item as? String, idStr == guide.id { return true }

            if let dict = item as? [String: Any],
               let id   = dict["id"] as? String,
               id == guide.id { return true }
        }
        return false
    }
    // MARK: - fetch saved guides
    func fetchSavedGuides() async -> [GuideSummary] {
        guard let uid = user?.id else { return [] }

        do {
            // kullanıcının savedGuides alanını alma
            let userDoc = try await db.collection("users")
                                      .document(uid)
                                      .getDocument()
            let raw = userDoc.data()?["savedGuides"] as? [Any] ?? []

            //  (id, city?) çiftleri
            var pairs: [(id: String, city: String?)] = []

            for item in raw {
                if let idStr = item as? String {
                    pairs.append((idStr, nil))
                }
                else if let dict = item as? [String: Any],
                        let id   = dict["id"]   as? String {
                    let city = (dict["city"] as? String)?.lowercased()
                    pairs.append((id, city))
                }
            }

            guard !pairs.isEmpty else { return [] }


            var guides: [GuideSummary] = []

            for (id, cityOpt) in pairs where cityOpt != nil {
                let city = cityOpt!
                let doc  = try await db.collection("guides")
                                       .document(city)
                                       .collection("items")
                                       .document(id)
                                       .getDocument()
                if let g = guideFrom(doc: doc, overrideCity: city) { guides.append(g) }
            }

            let unknownIds = pairs.filter { $0.city == nil }.map { $0.id }
            if !unknownIds.isEmpty {
                let citySnaps = try await db.collection("guides").getDocuments()
                for cDoc in citySnaps.documents {
                    let city = cDoc.documentID
                    let items = try await db.collection("guides")
                                            .document(city)
                                            .collection("items")
                                            .whereField(FieldPath.documentID(),
                                                        in: unknownIds)
                                            .getDocuments()
                    for d in items.documents {
                        if let g = guideFrom(doc: d, overrideCity: city) {
                            guides.append(g)
                        }
                    }
                }
            }
            return guides
        } catch {
            print("Kaydedilen rehberler alınamadı:", error.localizedDescription)
            return []
        }
    }

    private func guideFrom(doc: DocumentSnapshot,
                           overrideCity city: String) -> GuideSummary? {
        guard let data = doc.data(),
              let title = data["title"]       as? String,
              let descr = data["description"] as? String,
              let cover = data["coverURL"]    as? String,
              let user  = data["username"]    as? String else { return nil }

        return GuideSummary(
            id: doc.documentID,
            title: title,
            description: descr,
            coverURL: cover,
            username: user,
            userPhotoURL: data["photoURL"] as? String,
            city: city
        )
    }
}
