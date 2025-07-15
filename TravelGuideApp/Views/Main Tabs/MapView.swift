//
//  ExploreView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @AppStorage("selectedCity") private var selectedCityKey: String = ""
    @State private var region: MKCoordinateRegion

    init() {
        let cityData = loadCountryCityData()
        if let country = cityData.first(where: { $0.cities.contains(where: { $0.city_key == UserDefaults.standard.string(forKey: "selectedCity") }) }),
           let selectedCity = country.cities.first(where: { $0.city_key == UserDefaults.standard.string(forKey: "selectedCity") }) {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: selectedCity.latitude, longitude: selectedCity.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    @State private var showCamera = false  
    @State private var showRoutes = false
    @State private var showSearch = false
    
    @State private var historicPlaces: [HistoricPlace] = []
    @State private var selectedPlace: HistoricPlace? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka planda Harita
                Map(coordinateRegion: $region, annotationItems: historicPlaces) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        MiniPlaceBar(place: place)
                            .onTapGesture {
                                selectedPlace = place
                            }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                // SOL ALT (ExploreBottomPanel)
                ExploreBottomPanel(showRoutes: $showRoutes, showSearch: $showSearch)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 16)
                    .padding(.bottom, 30)

                // SAĞ ALT (CameraButton)
                CameraButton {
                    showCamera = true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 16)
                .padding(.bottom, 30)
            }
            .sheet(isPresented: $showCamera) {
                NavigationView {
                    CustomCameraView()
                        .navigationBarTitle("Keşif Modu", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            showCamera = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(UIColor.main))
                                .imageScale(.large)
                                .padding(5)
                        })
                }
            }
            .sheet(isPresented: $showRoutes) {
                NavigationView {
                    RoutesView()
                        .navigationBarTitle("Rotalar", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            showRoutes = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(UIColor.main))
                                .imageScale(.large)
                                .padding(5)
                        })
                }
            }
            .sheet(isPresented: $showSearch) {
                NavigationView {
                    SearchView { place in
                        withAnimation {
                            region = MKCoordinateRegion(
                                center: place.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        }
                        showSearch = false
                    }
                    .navigationBarTitle("Arama", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                            showSearch = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(UIColor.main))
                                .imageScale(.large)
                                .padding(5)
                        })
                }
            }
            .sheet(item: $selectedPlace) { place in
                NavigationView {
                    InformationView(place: place)
                        .navigationBarTitle("Bilgi", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            selectedPlace = nil
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(UIColor.main))
                                .imageScale(.large)
                                .padding(5)
                        })
                }
            }
            .navigationTitle("Harita")
            .onAppear {
                let places = loadHistoricPlaces().filter { $0.city_key == selectedCityKey }
                historicPlaces = places
                
                if let country = loadCountryCityData().first(where: { $0.cities.contains(where: { $0.city_key == selectedCityKey }) }),
                   let selectedCity = country.cities.first(where: { $0.city_key == selectedCityKey }) {
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: selectedCity.latitude, longitude: selectedCity.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
}

#Preview {
    MapView()
}
