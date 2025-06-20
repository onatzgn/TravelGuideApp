import SwiftUI

struct IconCircleButton: View {
    let systemName: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                        Circle()
                            .fill(.ultraThinMaterial)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                )
        }
    }
}
