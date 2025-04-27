import SwiftUI
import MapKit

struct InformationView: View {
    let place: HistoricPlace

    var body: some View {
        VStack(spacing: 16) {
            Image(place.label)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.horizontal)

            Text(place.title)
                .font(.title)
                .fontWeight(.bold)

            Text(place.description ?? "")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                let coordinate = place.coordinate
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = place.title
                mapItem.openInMaps(launchOptions: nil)
            }) {
                Label("Haritalar'da Aç", systemImage: "map")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.main))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Text("Bu mekan hakkında bilgi almak ve hatıra para kazanmak için keşif modunda kameranı mekana doğru tut!")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }
}
