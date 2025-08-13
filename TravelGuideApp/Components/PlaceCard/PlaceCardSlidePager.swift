import SwiftUI

struct PlaceCardSlidePager: View {
    let place: PlaceCardData
    var onClose: (() -> Void)? = nil        // optional close callback

    // MARK: - Build slides (intro + details + reviews)
    private var slides: [Slide] {
        var list: [Slide] = [
            .init(kind: .intro,
                  title: place.title,
                  subtitle: nil,
                  text: place.description,
                  imageName: place.main_bg)
        ]
        list += place.slides.map {
            .init(kind: .detail,
                  title: $0.title,
                  subtitle: nil,
                  text: $0.description,
                  imageName: $0.background)
        }
        list.append(
            .init(kind: .reviews,
                  title: "Gidenler Ne Dedi?",
                  subtitle: nil,
                  text: "Bu mekân hakkında henüz yorum yapılmadı.",
                  imageName: nil)
        )
        return list
    }

    // MARK: - State
    @State private var index = 0

    var body: some View {
        ZStack {
            // Current slide
            currentSlideView
                .transition(.opacity)
                .animation(.easeInOut, value: index)

            // Tap areas (prev / next)
            HStack(spacing: 0) {
                Color.clear.contentShape(Rectangle())
                    .onTapGesture { goPrev() }

                Color.clear.contentShape(Rectangle())
                    .onTapGesture { goNext() }
            }

            // Progress bar
            VStack {
                progressBar
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))   // keep content inside card bounds
    }

    // MARK: - Components
    private var currentSlideView: some View {
        let slide = slides[index]
        return PlaceCardSingleSlide(
            background: slide.imageName ?? place.main_bg,
            title: slide.title ?? "",
            description: slide.text ?? ""
        )
    }

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<slides.count, id: \.self) { i in
                Rectangle()
                    .fill(i == index ? .white : .white.opacity(0.4))
            }
        }
        .frame(height: 4)     // fixed height prevents resizing
    }

    // MARK: - Navigation
    private func goNext() {
        if index < slides.count - 1 {
            index += 1
        } else {
            onClose?()
        }
    }

    private func goPrev() {
        if index > 0 { index -= 1 }
    }
}
