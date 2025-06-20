import SwiftUI

struct FloatingPlusButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color(UIColor.main))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
        }
    }
}
