import SwiftUI
import PhotosUI
import MapKit


struct Stop: Identifiable, Equatable {
    enum Category: CaseIterable, Identifiable {
        case shopping, food, drink, history
        var id: Self { self }
        
        var iconName: String {
            switch self {
            case .shopping: return "bag.fill"
            case .food:     return "fork.knife"
            case .drink:    return "cup.and.saucer.fill"
            case .history:  return "building.columns"
            }
        }
        var title: String {
            switch self {
            case .shopping: return "Alışveriş"
            case .food:     return "Yeme"
            case .drink:    return "İçme"
            case .history:  return "Tarihi"
            }
        }
    }
    
    let id = UUID()
    var order: Int
    var place: MKMapItem? = nil
    var categories: Set<Category> = []
    var note: String = ""
}

struct CreateGuideView: View {
    

    enum Step { case intro, details }
    @State private var step: Step = .intro
    

    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity")    private var selectedCity:    String = ""
    

    @State private var guideTitle: String = ""
    @State private var guideDescription: String = ""
    @State private var coverImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    

    @State private var stops: [Stop] = [.init(order: 1)]
    @State private var selectedStopIndex: Int = 0
    @State private var showPlaceSearch = false


    @State private var isUploading = false
    @State private var uploadDone  = false
    @State private var showSavedToast = false

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            NavigationStack {
                switch step {
                case .intro:
                    introForm
                        .navigationTitle("Yeni Rehber")
                        .navigationBarTitleDisplayMode(.inline)
                case .details:
                    detailsForm
                        .navigationTitle("Duraklar")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                          
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    step = .intro
                                } label: {
                                    Label("Geri", systemImage: "chevron.left")
                                }
                            }
                       
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(role: .destructive) {
                                    resetForm()
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                }
            }


            if showSavedToast {
                Color.black.opacity(0.25).ignoresSafeArea()
                Text("Taslak kaydedildi")
                    .font(.title3.bold())
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            } else if isUploading {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView("Yükleniyor…")
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            } else if uploadDone {
                Color.black.opacity(0.25).ignoresSafeArea()
                Text("Paylaşıldı!")
                    .font(.title2.bold())
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .task { loadDraftIfAny() }
    }
    

    private var introForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
              
                VStack(alignment: .leading, spacing: 6) {
                    Text("Şehir").font(.headline)
                    LocationPickerView()
                }
                
            
                VStack(alignment: .leading, spacing: 6) {
                    Text("Başlık").font(.headline)
                    TextField("Rehberin için bir başlık yaz", text: $guideTitle)
                        .textFieldStyle(.roundedBorder)
                }
                
      
                VStack(alignment: .leading, spacing: 6) {
                    Text("Açıklama").font(.headline)
                    TextEditor(text: $guideDescription)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: .systemGray4))
                        )
                        .overlay(placeholder(text: "Rehberin için bir açıklama yazısı ekle",
                                             show: guideDescription.isEmpty))
                }
                
     
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kapak Resmi").font(.headline)
                    
                    PhotosPicker(selection: $pickerItem,
                                 matching: .images,
                                 photoLibrary: .shared()) {
                        ZStack {
                            if let img = coverImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundColor(Color(uiColor: .systemGray4))
                                    .frame(height: 180)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.system(size: 44))
                                            Text("Galeriden resim seç")
                                                .font(.callout)
                                        }
                                        .foregroundColor(.secondary)
                                    )
                            }
                        }
                    }
                    .onChange(of: pickerItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                coverImage = uiImage
                            }
                        }
                    }
                }
                
    
                Button {
                    step = .details
                } label: {
                    Text("Devam Et")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.main))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
    

    private var detailsForm: some View {
        VStack(spacing: 24) {
            
         
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    
                    ForEach(stops) { stop in
                        let index = stops.firstIndex(of: stop)!
                        Button {
                            selectedStopIndex = index
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(index == selectedStopIndex
                                          ? Color(UIColor.main)
                                          : .secondary.opacity(0.25))
                                    .frame(width: 72, height: 72)
                                Text("\(stop.order)")
                                    .font(.title.bold())
                                    .foregroundColor(index == selectedStopIndex ? .white : .primary)
                            }
                        }
                        .animation(.easeInOut, value: selectedStopIndex)
                    }
                    
                
                    Button {
                        addStop()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.main).opacity(0.2))
                                .frame(width: 48, height: 48)
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(Color(UIColor.main))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
            
      
            Form {
        
                Section("Mekan") {
                    Button {
                        showPlaceSearch = true
                    } label: {
                        HStack {
                            Text(stops[selectedStopIndex].place?.name ?? "Seç")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
         
                Section("Kategori") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                        ForEach(Stop.Category.allCases) { cat in
                            let isOn = stops[selectedStopIndex].categories.contains(cat)
                            Button {
                                toggleCategory(cat)
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: cat.iconName)
                                        .font(.title2)
                                    Text(cat.title)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 72, height: 72)
                                .background(isOn ? Color(UIColor.main) : Color(UIColor.systemGray5))
                                .foregroundColor(isOn ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
                
          
                Section("Not") {
                    TextEditor(text: Binding(
                        get: { stops[selectedStopIndex].note },
                        set: { stops[selectedStopIndex].note = $0 }
                    ))
                    .frame(minHeight: 120)
                }
            }
            .sheet(isPresented: $showPlaceSearch) {
                PlaceSearchView { item in
                    stops[selectedStopIndex].place = item
                }
            }
            
 
            VStack(spacing: 12) {
                Button("Paylaş") {
                    Task {
                        guard let image = coverImage else { return }
                        isUploading = true
                        do {
                            try await AuthService.shared.shareGuide(
                                city: selectedCity.lowercased(),
                                title: guideTitle,
                                description: guideDescription,
                                coverImage: image,
                                stops: stops
                            )
                        
                            isUploading = false
                            clearDraft()
                            uploadDone  = true
                            
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            dismiss()
                        } catch {
                            isUploading = false
                            print("Paylaşım hatası:", error)
                        }
                    }
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.main))
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(coverImage == nil || guideTitle.isEmpty || selectedCity.isEmpty)
                
                Button("Taslaklara Kaydet") {
                    saveDraft()
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.25))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    

    private func addStop() {
        stops.append(.init(order: stops.count + 1))
        selectedStopIndex = stops.count - 1
    }
    
    private func toggleCategory(_ cat: Stop.Category) {
        if stops[selectedStopIndex].categories.contains(cat) {
            stops[selectedStopIndex].categories.remove(cat)
        } else {
            stops[selectedStopIndex].categories = [cat]
        }
    }
    
  
    @ViewBuilder
    private func placeholder(text: String, show: Bool) -> some View {
        if show {
            HStack {
                Text(text)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                Spacer()
            }
        } else { EmptyView() }
    }

    
    private func saveDraft() {

        var coverB64: String? = nil
        if let img = coverImage, let data = img.jpegData(compressionQuality: 0.8) {
            coverB64 = data.base64EncodedString()
        }

        let draft = DraftGuide(
            country: selectedCountry,
            city: selectedCity,
            title: guideTitle,
            desc:  guideDescription,
            coverBase64: coverB64,
            stops: stops.map { stop in
                DraftStop(
                    order: stop.order,
                    latitude: stop.place?.placemark.coordinate.latitude,
                    longitude: stop.place?.placemark.coordinate.longitude,
                    placeName: stop.place?.name,
                    categories: stop.categories.map { $0.rawValue },
                    note: stop.note
                )
            }
        )
        DraftStorage.save(draft)
        showToast()
    }

    private func loadDraftIfAny() {
        guard let draft = DraftStorage.load() else { return }
        selectedCountry   = draft.country
        selectedCity      = draft.city
        guideTitle        = draft.title
        guideDescription  = draft.desc

        if let b64 = draft.coverBase64,
           let data = Data(base64Encoded: b64),
           let img  = UIImage(data: data) {
            coverImage = img
        }

        stops = draft.stops.map { d in
            var s = Stop(order: d.order)
            if let lat = d.latitude, let lon = d.longitude {
                let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                let item = MKMapItem(placemark: placemark)
                item.name = d.placeName
                s.place = item
            }
            s.categories = Set(d.categories.compactMap { Stop.Category(rawValue: $0) })
            s.note = d.note
            return s
        }

        step = stops.count > 1 || stops[0].place != nil ? .details : .intro
    }

    private func clearDraft() {
        DraftStorage.clear()
    }

    private func showToast() {
        withAnimation { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showSavedToast = false }
            dismiss()
        }
    }

    private func resetForm() {
        guideTitle = ""
        guideDescription = ""
        coverImage = nil
        pickerItem = nil
        stops = [.init(order: 1)]
        selectedStopIndex = 0
        step = .intro
        clearDraft()
    }
}
