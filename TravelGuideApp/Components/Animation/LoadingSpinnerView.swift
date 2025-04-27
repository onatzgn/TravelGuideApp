import SwiftUI
import Lottie

struct LoadingSpinnerView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let animationView = LottieAnimationView(name: "loadingAnimation") // .json uzantısı yok
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.play()

        let container = UIView()
        container.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 200), // büyütüldü
            animationView.heightAnchor.constraint(equalToConstant: 200)
        ])

        return container
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
