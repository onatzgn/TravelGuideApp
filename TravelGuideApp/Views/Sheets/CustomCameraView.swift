import SwiftUI

struct CustomCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var camera = CameraViewModel()
    @State private var predictedLabel: String = ""
    @State private var showPlaceInfo: Bool = false
    @State private var isLoading: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var recognitionFailed: Bool = false
    // Sosyal paylaşımlar (örnek veri – Firestore’dan doldurulabilir)
    @State private var shares: [SocialShare] = []        // Firestore’dan dinamık yüklenir
    @State private var showPhotoSheet: Bool = false     // Modal kamera görünür mü?
    @State private var showSharedPhotoSheet: Bool = false
    /// Yorum yazma sayfası sheet'i
    @State private var showCommentSheet: Bool = false
    @State private var selectedShare: SocialShare? = nil
    @State private var showCommentDetail = false

    /// Seçilen mekan için yorumları Firestore’dan çeker
    /// Seçilen mekan için yorumları Firestore’dan çeker
    /// Seçilen mekan için yorumları Firestore’dan çeker
    @MainActor
    private func loadComments(for place: String) {
        Task {
            let items = await auth.comments(for: place)
            print("DEBUG loaded", items.count, "comments for", place)
            self.shares = items                       // UI güncellenir
        }
    }
    @MainActor
    private func loadShares(for place: String) {
        Task {
            let comments = await auth.comments(for: place)
            let photos = await auth.photoShares(for: place)
            self.shares = (comments + photos).sorted { $0.createdAt > $1.createdAt }
        }
    }
    @EnvironmentObject private var auth: AuthService
    
    var body: some View {
        ZStack {
            // 1) Kamera önizlemesi
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            if recognitionFailed {
                Color.red
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            VStack {
                HStack {
                    Spacer()
                }
                Spacer()
                
                // 3) Alttaki Fotoğraf Çekme Butonu
                if !showPlaceInfo && !recognitionFailed {
                    Button(action: {
                        isLoading = true
                        camera.takePhoto()
                    }) {
                        Image(systemName: "camera.viewfinder")
                            .foregroundColor(.white)
                            .font(.system(size: 36))
                            .padding(24)
                            .background(Color(UIColor.main))
                            .clipShape(Circle())
                    }
                }
                
            }
            
            if showPlaceInfo {
                VStack {
                    PlaceInfoView(placeLabel: predictedLabel) {
                        showPlaceInfo = false
                        predictedLabel = ""
                    }
                    
                    Spacer()
                    
                    // Paylaşımlar (sağa kaydırılabilir)
                    PlaceSocialSharings(shares: shares) { share in
                        selectedShare = share
                        if share.kind == .comment {
                            showCommentDetail = true
                        } else {
                            showSharedPhotoSheet = true
                        }
                    }
                    
                    // Alt sosyal etkileşim paneli
                    SocialInteractionPanel(
                        onAddComment: {
                            showCommentSheet = true   // Yorum sheet'ini göster
                        },
                        onTakePhoto: {
                            showPhotoSheet = true      // ▶️  Modal kamera aç
                        }
                    )
                }
                .transition(.move(edge: .bottom))
            }
            
            if showSuccessAnimation {
                VStack {
                    Spacer()
                        .frame(height: 180)
                    RecognitionSuccessAnimation()
                        .frame(width: 200, height: 200)
                        .transition(.scale)
                    Spacer()
                }
            }
            
            if isLoading {
                VStack(spacing: 8) {
                    Spacer()
                    VStack(spacing: 8) {
                        LoadingSpinnerView()
                            .frame(width: 100, height: 100)
                        Text("Mekan Tanınıyor...")
                            .foregroundColor(.white)
                            .font(.headline)
                            .bold()
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: isLoading)
                            .padding(.bottom,150)
                    }
                    Spacer()
                }
            }
            
            if recognitionFailed {
                VStack(spacing: 12) {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Mekan Tanınamadı")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        Text("Lütfen mekanı daha net bir açıdan tekrar çekmeyi deneyin")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .padding(.bottom,60)
                    Spacer()
                }
                .onAppear {
                    // Otomatik gizlemeden sonra buton görünür olacak
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        recognitionFailed = false
                    }
                }
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentModal(placeLabel: predictedLabel) {
                loadComments(for: predictedLabel)      // yeni yorum sonrası tazele
            }
            .environmentObject(auth)
        }
        .sheet(isPresented: $showPhotoSheet) {
            PhotoCaptureModal(predictedLabel: predictedLabel)
                .environmentObject(auth)     // Yeni modal kamera
        }
        .sheet(isPresented: $showCommentDetail) {
            if let share = selectedShare {
                CommentDetailSheet(share: share)
            }
        }
        .sheet(isPresented: $showSharedPhotoSheet) {
            if let share = selectedShare {
                PhotoDetailSheet(share: share)
            }
        }
        .onAppear {
            // Ekrana gelince kamerayı başlat
            camera.startSession()
            camera.onClassificationResult = { label in
                isLoading = false
                if label == "unknown" {
                    recognitionFailed = true
                } else {
                    // Hatıra para ekle
                    Task { await auth.addCoin(label) }
                    predictedLabel = label
                    loadShares(for: label)              // Yorum + fotoğraf getir
                    showSuccessAnimation = true
                    // Delay before showing place info
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            showSuccessAnimation = false
                            showPlaceInfo = true
                        }
                    }
                }
            }
        }
        .onDisappear {
            // Sayfadan çıkınca durdur
            camera.stopSession()
        }
    }
}
