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
                    Circle()
                        .fill(.ultraThinMaterial) // hafif blur‑lu yarı şeffaf
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                )
        }
    }
}
