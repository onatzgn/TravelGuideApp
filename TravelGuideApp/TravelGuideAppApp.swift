//
//  TravelGuideAppApp.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth        // ekle
import FirebaseFirestore   // ekle
import FirebaseStorage

let db = Firestore.firestore(database: "travelguidedb")     // shared Firestore instance

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    quickTest()
    return true
  }
}
private func quickTest() {
    Task {
        do {
            // (A) Geçici çözüm: oturum açmadan dene
            // let _ = Auth.auth().currentUser   // nil de olsa sorun değil

            try await db.collection("test").addDocument(data: ["created": Date()])
            print("Firebase çalışıyor 🎉")
        } catch {
            print("Firebase HATA →", error.localizedDescription)
        }
    }
}


@main
struct TravelGuideAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate   // <-- ekli
    @StateObject private var auth = AuthService.shared        // 🔸
    @State private var isLoading = true


    var body: some Scene {

        WindowGroup {
            Group {
                if isLoading {
                    ProgressView("Yükleniyor...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                } else if auth.user == nil {
                    LoginView()
                        .environmentObject(auth)
                } else {
                    MainView()
                        .environmentObject(auth)
                }
            }
            .task {
                await auth.restoreSession()
                isLoading = false
            }
            .alert(item: $auth.errorMessage) { err in
                Alert(title: Text("Hata"),
                      message: Text(err.message),
                      dismissButton: .default(Text("Tamam")))
            }
        }
    }
}
