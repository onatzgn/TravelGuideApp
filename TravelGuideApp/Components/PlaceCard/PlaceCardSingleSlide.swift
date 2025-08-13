import SwiftUI

struct PlaceCardSingleSlide: View {
    let background: String
    let title: String
    let description: String

    private let cardSize = CGSize(width: 300, height: 520)

    var body: some View {
        ZStack {
            // Background image fills card size and clips properly
            Image(background)
                .resizable()
                .scaledToFill()
                .frame(width: cardSize.width, height: cardSize.height)
                .clipped()
                .overlay(Color.black.opacity(0.45))

            // Text content
            VStack(alignment: .leading, spacing: 12) {
                Spacer().frame(height: 40) // space for progress bar
                Text(title)
                    .font(.title2).bold()
                Text(description)
                    .font(.body)
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .frame(width: cardSize.width, height: cardSize.height, alignment: .topLeading)
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
