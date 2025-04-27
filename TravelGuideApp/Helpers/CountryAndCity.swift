import Foundation

struct Country: Identifiable, Codable {
    var id: String { country_key }
    let country_key: String
    let country_name: String
    let cities: [City]
}

struct City: Identifiable, Codable {
    var id: String { city_key }
    let city_key: String
    let city_name: String
    let latitude: Double
    let longitude: Double
}
