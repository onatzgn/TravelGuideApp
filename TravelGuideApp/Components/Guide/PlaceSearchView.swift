import SwiftUI
import MapKit

struct PlaceSearchView: View {
    @Environment(\.dismiss) private var dismiss
    var onSelect: (MKMapItem) -> Void
    
    @State private var query = ""
    @State private var results: [MKMapItem] = []
    
    var body: some View {
        NavigationStack {
            List(results, id: \.self) { item in
                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Sonuç").font(.headline)
                        if let address = item.placemark.title {
                            Text(address)
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Mekan ara")
            .onSubmit(of: .search, runSearch)
            .navigationTitle("Mekan Seç")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
    
    private func runSearch() {
        let req = MKLocalSearch.Request(); req.naturalLanguageQuery = query
        Task {
            let resp = try? await MKLocalSearch(request: req).start()
            await MainActor.run { results = resp?.mapItems ?? [] }
        }
    }
}
