import SwiftUI

struct SearchView: View {
    @AppStorage("selectedCity") private var selectedCityKey: String = ""
    @State private var searchText = ""
    var historicPlaces: [HistoricPlace] {
        loadHistoricPlaces().filter { $0.city_key == selectedCityKey }
    }
    var onPlaceSelected: (HistoricPlace) -> Void

    var filteredPlaces: [HistoricPlace] {
        if searchText.isEmpty {
            return historicPlaces
        } else {
            return historicPlaces.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top)

                if filteredPlaces.isEmpty {
                    Spacer()
                    VStack {
                        Text("Bu şehirde henüz keşfedilecek bir yer eklenmemiş.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    Spacer()
                } else {
                    List(filteredPlaces) { place in
                        PlaceSearchRow(place: place) {
                            onPlaceSelected(place)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
