import SwiftUI

struct FollowCountButton: View {
    var title: String      
    var count: Int
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.headline.weight(.bold))
            Text(title)
                .font(.footnote.weight(.medium))
        }
        .foregroundColor(.primary)
        .onTapGesture { action() }
    }
}
