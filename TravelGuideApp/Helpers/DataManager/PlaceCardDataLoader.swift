import Foundation

/// `loadHistoricPlaces()` fonksiyonu bozulmasın diye yeni loader ayrı.
func loadPlaceCards() -> [PlaceCardData] {
    guard let url = Bundle.main.url(forResource: "historical_places", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([PlaceCardData].self, from: data)
    else { return [] }
    return decoded
}

func placeCard(for label: String) -> PlaceCardData? {
    loadPlaceCards().first { $0.label == label }
}
