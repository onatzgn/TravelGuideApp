import Foundation

/// Görsel sunumda kullanılan tekil slaytı temsil eder
struct Slide: Identifiable {
    enum Kind { case intro, detail, reviews }
    
    let id = UUID()
    let kind: Kind
    let title: String?
    let subtitle: String?
    let text: String?
    let imageName: String?
}
