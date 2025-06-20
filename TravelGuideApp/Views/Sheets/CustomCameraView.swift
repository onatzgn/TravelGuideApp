import SwiftUI
import CoreLocation

struct CustomCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var camera = CameraViewModel()
    @StateObject private var verifier = LocationVerifier()
    @State private var showDistanceAlert = false
    @State private var notCloseEnoughLabel: String?
    @State private var predictedLabel: String = ""
    @State private var showPlaceInfo: Bool = false
    @State private var isLoading: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var recognitionFailed: Bool = false

    @State private var shares: [SocialShare] = []
    @State private var showPhotoSheet: Bool = false
    @State private var showSharedPhotoSheet: Bool = false

    @State private var showCommentSheet: Bool = false
    @State private var selectedShare: SocialShare? = nil
    @State private var showCommentDetail = false

 
    @MainActor
    private func loadComments(for place: String) {
        Task {
            let items = await auth.comments(for: place)
            print("DEBUG loaded", items.count, "comments for", place)
            self.shares = items
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
       
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            if recognitionFailed || showDistanceAlert {
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
                    
                    
                    PlaceSocialSharings(shares: shares) { share in
                        selectedShare = share
                        if share.kind == .comment {
                            showCommentDetail = true
                        } else {
                            showSharedPhotoSheet = true
                        }
                    }
                    
                   
                    SocialInteractionPanel(
                        onAddComment: {
                            showCommentSheet = true
                        },
                        onTakePhoto: {
                            showPhotoSheet = true
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
            
            if recognitionFailed || showDistanceAlert {
                VStack(spacing: 12) {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Mekan Doğrulanamadı")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        Text("Lütfen konuma yaklaşın veya mekanı daha net bir açıdan tekrar çekmeyi deneyin")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .padding(.bottom,60)
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if recognitionFailed { recognitionFailed = false }
                        if showDistanceAlert { showDistanceAlert = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentModal(placeLabel: predictedLabel) {
                loadComments(for: predictedLabel)
            }
            .environmentObject(auth)
        }
        .sheet(isPresented: $showPhotoSheet) {
            PhotoCaptureModal(predictedLabel: predictedLabel)
                .environmentObject(auth)
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
           
            AppEnvironment.isTest = false
            AppEnvironment.manualLocation = CLLocationCoordinate2D(
                latitude: 41.008573,
                longitude: 28.980153
            )
            camera.startSession()
            verifier.start()
            camera.onClassificationResult = { label in
                isLoading = false
         
                if let loc = verifier.currentLocation {
                    print("📍 Current location at capture: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                } else if let testLoc = AppEnvironment.manualLocation {
                    print("📍 Test location at capture: \(testLoc.latitude), \(testLoc.longitude)")
                } else {
                    print("📍 Location unavailable at capture")
                }
                if label == "unknown" {
                    recognitionFailed = true
                } else if let place = loadHistoricPlaces()
                            .first(where: { $0.label.lowercased() == label.lowercased() }),
                          verifier.isWithin(of: place) {
                    Task { await auth.addCoin(label) }
                    predictedLabel = label
                    loadShares(for: label)
                    showSuccessAnimation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            showSuccessAnimation = false
                            showPlaceInfo = true
                        }
                    }
                } else {
                    notCloseEnoughLabel = label
                    showDistanceAlert = true
                }
            }
        }
        .onDisappear {
            
            camera.stopSession()
            verifier.stop()
        }
    }
}
