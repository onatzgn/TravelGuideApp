//
//  MainView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {

        TabView {
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            ExploreView()
                .tabItem {
                    Label("Keşfet", systemImage: "safari.fill")
                }
            
            MapView()
                .tabItem {
                    Label("Harita", systemImage: "globe.europe.africa.fill")
                }
            
            CollectionView()
                .tabItem {
                    Label("Koleksiyon", systemImage: "square.stack.fill")
                }
            
            SocialView()
                .tabItem {
                    Label("Sosyal", systemImage: "person.3.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
        .accentColor(Color("MainColor"))
        .onAppear {
            /*
            let path = "/Users/onatozgen/Documents/Swift Proje/TravelGuideApp/TravelGuideApp/Asset/test_deneme/test"
            let folderURL = URL(fileURLWithPath: path)
            let tester = BatchImageTester()
            tester.evaluateDataset(at: folderURL)
            */
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            /*
            if let folderURL = Bundle.main.url(forResource: "test", withExtension: nil, subdirectory: "test_deneme") {
                print(" Test klasörü bulundu (path yöntemi): \(folderURL)")
                let tester = BatchImageTester()
                tester.evaluateDataset(at: folderURL)
            } else {
                print(" Test klasörü bulunamadı (path yöntemi).")
            }

            */
            }
        }
    }

#Preview {
    MainView()
}
