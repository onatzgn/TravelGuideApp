import SwiftUI

struct EditProfileButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text("Düzenle")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 2)
                                .shadow(color: .black.opacity(0.2),
                                        radius: 2, x: 0, y: 1)
                        )
                )
        }
    }
}
