import SwiftUI

struct DrawerView: View {
    var onSignOut: () -> Void
    var onClose: () -> Void = {}

    var body: some View {
        VStack {
            Spacer()
            Button(action: onSignOut) {
                Text("Çıkış Yap")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .frame(width: 220)
        .background(Color(.systemGray6))
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .vertical)
        .shadow(radius: 4)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        onClose()
                    }
                }
        )
    }
}
