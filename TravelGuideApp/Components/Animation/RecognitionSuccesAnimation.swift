import SwiftUI
import Lottie

struct RecognitionSuccessAnimation: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let animationView = LottieAnimationView(name: "recognitionSuccess") // .json uzantısı yok
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        animationView.play()

        let container = UIView()
        container.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200)
        ])

        return container
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
