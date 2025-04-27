import SwiftUI

struct CountryCityPicker: View {
    @Binding var selectedCountry: String
    @Binding var selectedCity: String

    @State private var countryCityData: [Country] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ülke Seç").font(.headline)
            
            Picker("Ülke", selection: $selectedCountry) {
                ForEach(countryCityData) { country in
                    Text(country.country_name).tag(country.country_key)
                }
            }
            .pickerStyle(.menu)

            if let selected = countryCityData.first(where: { $0.country_key == selectedCountry }) {
                Text("Şehir Seç").font(.headline)
                
                Picker("Şehir", selection: $selectedCity) {
                    ForEach(selected.cities) { city in
                        Text(city.city_name).tag(city.city_key)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding()
        .onAppear {
            countryCityData = loadCountryCityData()
            if selectedCountry.isEmpty, let first = countryCityData.first {
                selectedCountry = first.country_key
                selectedCity = first.cities.first?.city_key ?? ""
            }
        }
    }
}
