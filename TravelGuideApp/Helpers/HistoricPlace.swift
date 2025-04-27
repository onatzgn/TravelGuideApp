import Foundation
import CoreLocation

struct HistoricPlace: Identifiable, Codable {
    let id = UUID()
    let label: String
    let title: String
    let latitude: Double
    let longitude: Double
    let description: String?
    let country: String
    let city: String
    let district: String
    let city_key: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
