import SwiftUI

struct CameraButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "eye.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundColor(.white)
                .opacity(0.8)
                .padding()
                .background(Color(UIColor.main))
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .opacity(0.8)
    }
}
