import SwiftUI

struct PlaceCardInfoView: View {
    let placeLabel: String
    var onClose: () -> Void
    
    var body: some View {
        if let data = placeCard(for: placeLabel) {
            PlaceCardView(place: data)
        } else {
            Text("Veri bulunamadı")
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PlaceCardInfoView(placeLabel: "alman_cesmesi", onClose: {})
        .padding()
}
