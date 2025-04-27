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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                VStack {
                    Spacer() 
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
