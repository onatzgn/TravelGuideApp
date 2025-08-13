import SwiftUI
import Combine

private struct SlideContent: Identifiable {
    let id = UUID()
    let bg: String
    let title: String
    let desc: String
}

struct PlaceCard: View {
    let place: PlaceCardData

    // Kart boyutu
    private let cardSize = CGSize(width: 360, height: 630)

    // Mod durumları
    @State private var showSlides = false
    @State private var index      = 0
    @State private var slideTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var elapsed: Double = 0        // seconds elapsed on this slide

    // JSON slaytları + yorum slaytı
    private var slideContents: [SlideContent] {
        place.slides.map { SlideContent(bg: $0.background,
                                        title: $0.title,
                                        desc: $0.description) }
    }
    private var totalSlides: Int { slideContents.count + 1 }   // +1 yorum

    var body: some View {
        ZStack {
            if showSlides { slideMode } else { introMode }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 4)
        .onReceive(slideTimer) { _ in
            guard showSlides && index < slideContents.count else { return }
            // ilerleme: 0‑5 sn
            elapsed += 0.05
            if elapsed >= 5 {
                elapsed = 0
                if index < totalSlides - 1 {
                    index += 1           // JSON → sonraki / Comment’a geç
                } else {
                    showSlides = false   // Comment’te dur
                }
            }
        }
    }

    // MARK: Intro
    private var introMode: some View {
        ZStack {
            Image(place.main_bg)
                .resizable()
                .scaledToFill()
                .frame(width: cardSize.width, height: cardSize.height)
                .clipped()
                .overlay(Color.black.opacity(0.35))

            VStack(spacing: 14) {
                Image(place.label)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                Text(place.title)
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text("\(place.district), \(place.city), \(place.country)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                Text(place.description)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    index = 0
                    elapsed = 0
                    showSlides = true
                } label: {
                    Text("İncele")
                        .font(.headline.weight(.semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 28)
                }
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.top, 8)
            }
            .padding()
        }
    }

    // MARK: Slaytlar
    private var slideMode: some View {
        ZStack {
            // Arka plan
            if index < slideContents.count {
                Image(slideContents[index].bg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.35))
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.sRGB, white: 0.12, opacity: 1),
                                                Color(.sRGB, white: 0.04, opacity: 1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    Text("Gidenler\nNe Dedi?")
                        .font(.system(size: 56, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: .black.opacity(0.7), radius: 8, x: 0, y: 4)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 24)
                        .padding(.bottom, 28),
                    alignment: .bottomLeading
                )
            }

            // Progress bar + place title
            VStack(spacing: 8) {
                // küçük mekan adı
                Text(place.title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 12)

                progressBar
                    .padding(.horizontal, 20)

                Spacer()
            }

            // İçerik veya yorum
            if index < slideContents.count {
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    Text(slideContents[index].title)
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text(slideContents[index].desc)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 20) {
                    Text("")
                        .font(.headline)
                        .padding(.top, 40)
                        .foregroundColor(.white)
                    Text("Bu mekân hakkında henüz yorum yapılmadı.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                .padding()
            }
        }
        // Tap overlay
        .overlay(
            HStack(spacing: 0) {
                Color.clear.contentShape(Rectangle())
                    .onTapGesture {
                        if index > 0 {
                            index -= 1
                            elapsed = 0
                        }
                    }
                Color.clear.contentShape(Rectangle())
                    .onTapGesture {
                        if index < totalSlides - 1 {
                            index += 1
                            elapsed = 0
                        } else {
                            showSlides = false // yorumdan çıkınca intro
                        }
                    }
            }
        )
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSlides, id: \.self) { i in
                GeometryReader { geo in
                    let fullWidth = geo.size.width
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color.white)
                                .frame(width:
                                    i < index ? fullWidth :
                                    i == index ?
                                        (index == slideContents.count ? fullWidth : fullWidth * CGFloat(elapsed / 5))
                                    : 0)
                        }
                }
                .frame(height: 5)
            }
        }
        .frame(height: 5)
    }
}
