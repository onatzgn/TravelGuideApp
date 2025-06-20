//
//  DraftGuide.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 13.05.2025.
//

import Foundation
import UIKit
import CoreLocation


struct DraftStop: Codable {
    var order: Int
    var latitude: Double?
    var longitude: Double?
    var placeName: String?
    var categories: [String]
    var note: String
}

struct DraftGuide: Codable {
    var country: String
    var city:    String
    var title:   String
    var desc:    String
    var coverBase64: String?
    var stops:  [DraftStop]
}


enum DraftStorage {
    private static let key = "draft_guide"

    static func save(_ draft: DraftGuide) {
        if let data = try? JSONEncoder().encode(draft) {
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: key)
            defaults.synchronize()
        }
    }

    static func load() -> DraftGuide? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(DraftGuide.self, from: data)
    }

    static func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
}

extension Stop.Category: RawRepresentable {
    public typealias RawValue = String
    public init?(rawValue: String) {
        guard let value = Self.allCases.first(where: { "\($0)" == rawValue }) else { return nil }
        self = value
    }
    public var rawValue: String { "\(self)" }
}
