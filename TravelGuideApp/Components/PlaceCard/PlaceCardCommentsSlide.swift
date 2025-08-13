import SwiftUI

struct PlaceCardCommentsSlide: View {
    let place: PlaceCardData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Gidenler Ne Dedi?")
                .font(.headline)
                .padding(.top, 40)
            
            // Henüz yorum yok
            Text("Bu mekân hakkında henüz yorum yapılmadı.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundColor(.white)
        .ignoresSafeArea()
    }
}
