import SwiftUI

struct LocationPickerView: View {
    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity") private var selectedCity: String = ""
    @State private var showPicker = false
    @State private var countryCityData: [Country] = []
    
    enum SelectionStep {
        case country, city
    }
    @State private var selectionStep: SelectionStep = .country

    var body: some View {
        Button(action: {
            showPicker.toggle()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.gray)
                Text(cityDisplayName + ", " + countryDisplayName)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial.opacity(1))
            .cornerRadius(10)
        }
        .onAppear {
            countryCityData = loadCountryCityData()
            selectedCountry = UserDefaults.standard.string(forKey: "selectedCountry") ?? selectedCountry
            selectedCity = UserDefaults.standard.string(forKey: "selectedCity") ?? selectedCity
        }
        .sheet(isPresented: $showPicker, content: {
            pickerSheetContent()
                .presentationDetents([.medium])
        })
    }

    private var countryDisplayName: String {
        countryCityData.first(where: { $0.country_key == selectedCountry })?.country_name ?? ""
    }

    private var cityDisplayName: String {
        countryCityData
            .first(where: { $0.country_key == selectedCountry })?
            .cities.first(where: { $0.city_key == selectedCity })?
            .city_name ?? ""
    }

    @ViewBuilder
    private func pickerSheetContent() -> some View {
        VStack {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            VStack(spacing: 14) {
                Text(selectionStep == .country ? "Ülke Seç" : "Şehir Seç")
                    .font(.title).bold()

                if selectionStep == .country {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(countryCityData) { country in
                                Button(action: {
                                    selectedCountry = country.country_key
                                    UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
                                }) {
                                    Text(country.country_name)
                                        .fontWeight(selectedCountry == country.country_key ? .bold : .regular)
                                        .foregroundColor(selectedCountry == country.country_key ? Color(UIColor.main) : .primary)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.vertical, 100) // Adjust based on actual frame height
                    }
                    .scrollIndicators(.hidden)
                    .mask(gradientMask)
                    .frame(height: 200)

                    Button(action: {
                        if let firstCity = countryCityData
                            .first(where: { $0.country_key == selectedCountry })?
                            .cities.first {
                            selectedCity = firstCity.city_key
                        }
                        selectionStep = .city
                    }) {
                        Text("Seç")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.main))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                } else if selectionStep == .city {
                    if let selected = countryCityData.first(where: { $0.country_key == selectedCountry }) {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(selected.cities) { city in
                                    Button(action: {
                                        selectedCity = city.city_key
                                    }) {
                                        Text(city.city_name)
                                            .fontWeight(selectedCity == city.city_key ? .bold : .regular)
                                            .foregroundColor(selectedCity == city.city_key ? Color(UIColor.main) : .primary)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }
                            .padding(.vertical, 100)
                        }
                        .scrollIndicators(.hidden)
                        .mask(gradientMask)
                        .frame(height: 200)

                        Button(action: {
                            showPicker = false
                            UserDefaults.standard.set(selectedCity, forKey: "selectedCity")
                            selectionStep = .country
                        }) {
                            Text("Seç")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.main))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top, 80)
        }
        .padding()
    }
    
    private var gradientMask: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.2),
                .init(color: .black, location: 0.8),
                .init(color: .clear, location: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
