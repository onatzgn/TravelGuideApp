import SwiftUI

struct FollowCountButton: View {
    var title: String          // “Takipçiler” / “Takip Edilenler”
    var count: Int
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.headline.weight(.bold))
            Text(title)
                .font(.footnote.weight(.medium))
        }
        .foregroundColor(.white)
        .onTapGesture { action() }
    }
}
