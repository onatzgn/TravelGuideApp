//
//  HomeView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity") private var selectedCity: String = ""
    @State private var guides: [GuideSummary] = []
    @State private var selectedGuide: GuideSummary? = nil
    @State private var stops: [Stop] = []
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        LocationPickerView()
                            .padding(.horizontal)

                        if !guides.isEmpty {
                            Text("Seyahat Rehberleri")
                                .font(.title2.bold())
                                .padding(.horizontal)

                            ForEach(guides) { guide in
                                GuideCardView(guide: guide) {
                                    // Kart tıklandığında sheet'i aç
                                    selectedGuide = guide
                                    stops = []          // önce temizle
                                    Task {
                                        stops = await AuthService.shared.fetchStops(forGuide: guide)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            Text("Bu şehirde henüz rehber paylaşılmamış.")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .task {
                    guides = await AuthService.shared.fetchGuides(for: selectedCity)
                }
                .onChange(of: selectedCity) { newCity in
                    Task {
                        guides = await AuthService.shared.fetchGuides(for: newCity)
                    }
                }
                .sheet(item: $selectedGuide) { guide in
                    GuideDetailSheetView(guide: guide, stops: stops)
                        .presentationDetents([.medium, .large])
                }

                HStack {
                    Spacer()
                    LocationPickerView()
                    .padding(.trailing, 16)
                }
                .padding(.top, -340)
            }
            .navigationTitle("Ana Sayfa")
        }
    }
}

#Preview {
    HomeView()
}
