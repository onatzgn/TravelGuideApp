import Foundation

// MARK: - Slide
struct PlaceCardSlide: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let background: String
}

// MARK: - Place
struct PlaceCardData: Identifiable, Codable {
    // Temel bilgiler
    let id = UUID()
    let label: String
    let title: String
    let description: String
    let country: String
    let city: String
    let district: String

    // Opsiyonel alanlar
    let main_bg: String
    let slides: [PlaceCardSlide]

    // ❶ – JSON’da bulunmazsa varsayılan değer ata
    private enum CodingKeys: String, CodingKey {
        case label, title, description, country, city, district, main_bg, slides
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        label       = try c.decode(String.self, forKey: .label)
        title       = try c.decode(String.self, forKey: .title)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        country     = try c.decodeIfPresent(String.self, forKey: .country)     ?? ""
        city        = try c.decodeIfPresent(String.self, forKey: .city)        ?? ""
        district    = try c.decodeIfPresent(String.self, forKey: .district)    ?? ""

        // `main_bg` ve `slides` yoksa otomatik üret
        main_bg = try c.decodeIfPresent(String.self, forKey: .main_bg) ?? "\(label)_main_bg"
        slides  = try c.decodeIfPresent([PlaceCardSlide].self, forKey: .slides) ?? []
    }
}
