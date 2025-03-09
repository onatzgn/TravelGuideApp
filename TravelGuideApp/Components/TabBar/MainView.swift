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
                    Label("Keşfet", systemImage: "map.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
        .accentColor(Color("MainColor"))
    }
}

#Preview {
    MainView()
}
