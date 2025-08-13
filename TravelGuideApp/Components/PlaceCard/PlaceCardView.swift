import SwiftUI

struct PlaceCardView: View {
    let place: PlaceCardData
    @State private var showSlides = false           // ⇠ yeni state
    private let cardSize = CGSize(width: 300, height: 520)

    var body: some View {
        ZStack {
            Image(place.main_bg)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: cardSize.width, height: cardSize.height)

            if showSlides {
                // SLAYT MODU
                PlaceCardSlidePager(place: place)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(width: cardSize.width, height: cardSize.height)
            } else {
                // GİRİŞ MODU
                introContent
                    .frame(width: cardSize.width, height: cardSize.height)
            }
        }
        .shadow(radius: 8)
    }

    // MARK: - Intro içeriği
    private var introContent: some View {
        VStack(spacing: 14) {
            Image(place.label)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)

            Text(place.title)
                .font(.title).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Text("\(place.district), \(place.city), \(place.country)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))

            Text(place.description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("İncele") { showSlides = true }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundColor(.black)
                .padding(.top, 8)
        }
        .padding()
    }
}
