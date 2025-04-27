import SwiftUI

struct LandmarkCoinSection: View {
    let coins: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hatıra Paralar")
                .font(.title3.bold())
                .padding(.horizontal)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(coins, id: \.self) { label in
                        Image(label)          // Xcode Asset’te “galata_kulesi.png” vs.
                            .resizable()
                            .interpolation(.high)
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 12)
        }
    }
}
