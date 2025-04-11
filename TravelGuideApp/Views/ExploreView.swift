//
//  ExploreView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI
import MapKit

struct ExploreView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var showCamera = false  // Kamerayı gösteren sheet kontrolü
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Arka planda Harita
                Map(coordinateRegion: $region)
                    .edgesIgnoringSafeArea(.all)
                
                // Sağ alt köşedeki Dairesel Buton
                CameraButton {
                    // Butona tıklanınca gerçekleşecek işlemler
                    showCamera = true
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            // Sheet (modal) olarak CameraView'u göster
            /*
            .sheet(isPresented: $showCamera) {
                // NavigationView içine alırsak sol üstte "Geri" butonu görebiliriz
            }
             */
            .sheet(isPresented: $showCamera) {
                // Possibly wrap CustomCameraView in a NavigationView if you want a back button
                NavigationView {
                    CustomCameraView()
                        .navigationBarTitle("Kamera", displayMode: .inline)
                        .navigationBarItems(leading: Button("Geri") {
                            showCamera = false
                        })
                }
            }
            .navigationTitle("Keşfet")

        }
    }
}

#Preview {
    ExploreView()
}
