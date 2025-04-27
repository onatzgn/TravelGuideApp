import SwiftUI
import AVFoundation

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish()
    }
}


struct PlaceInfoView: View {
    let placeLabel: String
    var onClose: () -> Void
    @State private var selectedIndex = 0
    private var placeInfo: PlaceInfo?

    init(placeLabel: String, onClose: @escaping () -> Void) {
        self.placeLabel = placeLabel
        self.onClose = onClose
        self.placeInfo = loadPlaceInfo(for: placeLabel)
    }

    var body: some View {
        if let placeInfo = placeInfo {
            VStack {
                ZStack(alignment: .topTrailing) {
                    PlaceInfoPanel(
                        placeTitle: placeInfo.title,
                        periods: placeInfo.history,
                        selectedIndex: $selectedIndex
                    )
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(Color(UIColor.main))
                    }
                    .offset(x: -5, y: 30)
                }.padding(.top, -30) 

                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.001))
        } else {
            Text("Bilgi bulunamadı.")
                .foregroundColor(.gray)
                .padding()
                .background(Color.black.opacity(0.001))
        }
    }
}

#Preview {
    PlaceInfoView(placeLabel: "kiz_kulesi", onClose: {})
}
