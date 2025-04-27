import SwiftUI

struct PlaceSearchRow: View {
    let place: HistoricPlace
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 12) {
                Image(place.label)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(place.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text("\(place.district), \(place.city), \(place.country)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
