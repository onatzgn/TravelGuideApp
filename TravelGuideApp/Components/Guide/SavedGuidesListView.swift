//
//  SavedGuidesListView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 11.05.2025.
//


import SwiftUI

struct SavedGuidesListView: View {
    @Binding var isPresented: Bool        
    var onSelect: (GuideSummary) -> Void

    @State private var localGuides: [GuideSummary] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(localGuides) { guide in
                        GuideCardView(guide: guide) {
                            isPresented = false        
                            onSelect(guide)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Kaydedilen Rehberler")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                localGuides = await AuthService.shared.fetchSavedGuides()
            }
        }
    }
}

#if DEBUG
struct SavedGuidesListView_Previews: PreviewProvider {
    static var previews: some View {
        SavedGuidesListView(isPresented: .constant(true)) { _ in }
    }
}
#endif
