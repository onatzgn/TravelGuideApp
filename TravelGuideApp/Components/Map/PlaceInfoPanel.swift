import SwiftUI
import AVFoundation

struct PlaceInfoPanel: View {
    let placeTitle: String
    let periods: [PlaceHistory]
    let synthesizer = AVSpeechSynthesizer()
    @Binding var selectedIndex: Int
    @State private var isSpeaking = false
    @State private var speechDelegate: SpeechDelegate?
    
    var body: some View {
        VStack(spacing: 8) {
            // Üst başlık
            HStack {
                ZStack {
                    VStack(spacing: 2) {
                        let titleComponents = placeTitle.split(separator: " ")
                        if titleComponents.count > 2 {
                            Text(titleComponents.dropLast().joined(separator: " "))
                                .font(.title)
                                .fontWeight(.bold)
                            Text(titleComponents.last!)
                                .font(.title)
                                .fontWeight(.bold)
                        } else {
                            Text(placeTitle)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                    )
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // Yıllar arası geçiş
            HStack {
                Button(action: {
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                }) {
                    Image(systemName: "arrowtriangle.left.circle.fill")
                        .fontWeight(.bold)
                        .foregroundColor(selectedIndex > 0 ? Color(UIColor.main) : .gray)
                }
                .disabled(selectedIndex == 0)
                .padding(.trailing, 8)

                Button(action: {
                    guard !isSpeaking else { return }

                    let utterance = AVSpeechUtterance(string: periods[selectedIndex].description)
                    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Yelda-compact")
                    utterance.rate = 0.55


                    let delegate = SpeechDelegate {
                        isSpeaking = false
                    }
                    self.speechDelegate = delegate
                    synthesizer.delegate = delegate

                    isSpeaking = true
                    synthesizer.speak(utterance)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "headphones")
                            .fontWeight(.bold)
                        Text(periods[selectedIndex].year)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .background(Color(UIColor.main).opacity(0.6))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                    )
                    .foregroundColor(.white)
                }

                Button(action: {
                    if selectedIndex < periods.count - 1 {
                        selectedIndex += 1
                    }
                }) {
                    Image(systemName: "arrowtriangle.right.circle.fill")
                        .fontWeight(.bold)
                        .foregroundColor(selectedIndex < periods.count - 1 ? Color(UIColor.main) : .gray)
                }
                .disabled(selectedIndex == periods.count - 1)
                .padding(.leading, 8)
            }
            .font(.headline)

            // Alt başlık
            Text(periods[selectedIndex].title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                )
                .padding(.bottom, 5)

            if isSpeaking {
                Button(action: {
                    synthesizer.stopSpeaking(at: .immediate)
                    isSpeaking = false
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.slash.fill")
                        Text("Sesli anlatımı durdur")
                    }
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .background(Color.red.opacity(0.4))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 1)
                    )
                }
                .padding(.bottom, 5)
            }
        }
        .cornerRadius(16)
        .padding()
    }
}
