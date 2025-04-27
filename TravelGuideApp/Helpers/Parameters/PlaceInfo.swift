import Foundation

struct PlaceHistory: Codable {
    let year: String
    let title: String
    let description: String
}

struct PlaceInfo: Codable {
    let label: String
    let title: String
    let history: [PlaceHistory]
}
