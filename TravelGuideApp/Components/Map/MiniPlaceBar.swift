import SwiftUI

struct MiniPlaceBar: View {
    let place: HistoricPlace

    var body: some View {
        VStack {
            Text(place.title)
                .font(.caption)
                .fontWeight(.bold)
                .padding(6)
                .shadow(radius: 5)
                .background(Color(UIColor.main))
                .foregroundColor(.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color(UIColor.darkGreen).opacity(0.6), lineWidth: 4))
            
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial.opacity(0.7))
                    .background(Circle().fill(Color(UIColor.darkGreen).opacity(0.6)))
                    .shadow(radius: 5)
                    .opacity(0.8)
                    .overlay(Circle().stroke(Color(UIColor.main).opacity(0.8), lineWidth: 4))
                Image(systemName: "mappin")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
                    .padding(3)
                    .opacity(0.8)
            }
        }
    }
}

