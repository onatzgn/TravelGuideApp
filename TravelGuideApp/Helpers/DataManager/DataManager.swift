import Foundation

func loadHistoricPlaces() -> [HistoricPlace] {
    guard let url = Bundle.main.url(forResource: "historical_places", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([HistoricPlace].self, from: data) else {
        return []
    }
    return decoded
}

func loadPlaceInfo(for label: String) -> PlaceInfo? {
    guard let url = Bundle.main.url(forResource: "place_info", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let allInfo = try? JSONDecoder().decode([PlaceInfo].self, from: data) else {
        return nil
    }
    return allInfo.first(where: { $0.label == label })
}

func loadCountryCityData() -> [Country] {
    guard let url = Bundle.main.url(forResource: "countries_and_cities", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([Country].self, from: data) else {
        return []
    }
    return decoded
}
