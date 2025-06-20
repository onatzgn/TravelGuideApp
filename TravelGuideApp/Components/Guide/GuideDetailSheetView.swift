//
//  GuideDetailSheetView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 11.05.2025.
//

import SwiftUI
import MapKit

struct GuideDetailSheetView: View {
    let guide: GuideSummary
    let stops: [Stop]
    
    @State private var selectedIndex = 0

    var body: some View {
        VStack {
            if stops.isEmpty {
                ProgressView("Yükleniyor...")
                    .padding()
            } else {
                VStack(spacing: 16) {
                   
                    HStack(spacing: 12) {
                        if let url = guide.userPhotoURL,
                           let imageURL = URL(string: url) {
                            AsyncImage(url: imageURL) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(guide.username)
                                .font(.subheadline)
                                .bold()
                            Text(guide.title)
                                .font(.headline)
                        }

                        Spacer()

                    }
                    .padding(.horizontal)

                    // durak baloncukları
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(stops.indices, id: \.self) { idx in
                                Button {
                                    selectedIndex = idx
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIndex == idx ? Color(UIColor.systemTeal) : .secondary.opacity(0.25))
                                            .frame(width: 64, height: 64)
                                        Text("\(stops[idx].order)")
                                            .font(.title3.bold())
                                            .foregroundColor(selectedIndex == idx ? .white : .primary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()

                    // durağın detayları
                    let stop = stops[selectedIndex]
                    VStack(alignment: .leading, spacing: 12) {
                        Text(stop.place?.name ?? "Bilinmeyen Mekan")
                            .font(.headline)

                        HStack {
                            ForEach(Array(stop.categories), id: \.self) { cat in
                                Label(cat.title, systemImage: cat.iconName)
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }

                        Button("Haritalar’da Aç") {
                            if let mapItem = stop.place {
                                mapItem.openInMaps(launchOptions: nil)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.systemTeal))

                        Divider()

                        Text(stop.note)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
        }
    }
}
