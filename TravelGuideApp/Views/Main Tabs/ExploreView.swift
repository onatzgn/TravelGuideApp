struct VerticalPageView<Content: View>: UIViewControllerRepresentable {
    private let interSpacing: CGFloat = 32   // spacing between pages
    var views: [UIHostingController<Content>]
    var initialIndex: Int              // which page to show first

    init(_ views: [Content], initialIndex: Int = 0) {
        self.views = views.map { UIHostingController(rootView: $0) }
        self.initialIndex = initialIndex
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let options: [UIPageViewController.OptionsKey : Any] = [
            .interPageSpacing: interSpacing
        ]
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: options)
        controller.dataSource = context.coordinator
        let start = min(max(0, initialIndex), views.count - 1)
        controller.setViewControllers([views[start]], direction: .forward, animated: false)
        // allow neighbouring pages to peek
        controller.view.clipsToBounds = false
        // capture the internal scroll view for scaling effect
        if let scroll = controller.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scroll.delegate = context.coordinator
            scroll.clipsToBounds = false
            context.coordinator.scrollView = scroll
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {}

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIScrollViewDelegate {
        var parent: VerticalPageView
        weak var scrollView: UIScrollView?

        init(_ parent: VerticalPageView) {
            self.parent = parent
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.views.firstIndex(of: viewController as! UIHostingController<Content>), index > 0 else {
                return nil
            }
            return parent.views[index - 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.views.firstIndex(of: viewController as! UIHostingController<Content>), index + 1 < parent.views.count else {
                return nil
            }
            return parent.views[index + 1]
        }

        // Scale pages so the centred one is 100%, others 90%
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let midY = scrollView.bounds.midY
            for vc in parent.views {
                guard let v = vc.view else { continue }
                let converted = scrollView.convert(v.frame, from: v.superview)
                let distance  = abs(converted.midY - midY)
                let progress  = min(distance / scrollView.bounds.height, 1)
                // Daha belirgin: merkezde %100, kenarda %80
                let scale     = 0.8 + (1 - progress) * 0.2
                v.transform   = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}
//
//  ExploreView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 15.07.2025.
//


import SwiftUI
import FirebaseFirestore

/// A wrapper that lets users swipe a card to the **right**.
/// When the user drags the card past a threshold it flies off‑screen
/// and triggers `onSwipedRight`, which we’ll later hook up to “save” logic.
struct DraggablePlaceCard: View {
    let place: PlaceCardData
    var onSwipedRight: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        PlaceCard(place: place)
            .offset(x: offset.width)
            .rotationEffect(.degrees(Double(offset.width / 15)))
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        // Accept drag only when it is a CLEAR right swipe (positive X)
                        if value.translation.width > 0,
                           value.translation.width > abs(value.translation.height) {
                            offset = CGSize(width: value.translation.width, height: 0)
                        }
                    }
                    .onEnded { value in
                        // Determine if this was a valid right‑swipe
                        let isRightSwipe = value.translation.width > 0 &&
                                           value.translation.width > abs(value.translation.height)

                        if isRightSwipe && value.translation.width > 100 {
                            // Swipe‑right accepted → animate off‑screen then notify
                            withAnimation(.easeOut(duration: 0.25)) {
                                offset.width = UIScreen.main.bounds.width
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onSwipedRight()
                            }
                        } else {
                            // Any other gesture (left swipe, short swipe, etc.) → snap back
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }
            )
    }
}

struct ExploreView: View {
    @State private var startIndex: Int = 0
    @State private var places: [PlaceCardData] = loadPlaceCards()  // ← JSON'dan gelen tüm veriler

    /// Called when a card is swiped right.
    /// For now it simply removes the card; later we’ll persist it.
    private func handleSwipeRight(place: PlaceCardData) {
        guard let idx = places.firstIndex(where: { $0.id == place.id }) else { return }

        withAnimation {
            places.remove(at: idx)
        }

        // Choose the page that should appear next
        if !places.isEmpty {
            startIndex = min(idx, places.count - 1)
        }
        // TODO: save this place to favourites
    }

    var body: some View {
        NavigationStack {
            VerticalPageView(
                places.map { place in
                    DraggablePlaceCard(place: place) {
                        handleSwipeRight(place: place)
                    }
                },
                initialIndex: startIndex
            )
            .id(places.count)  // recreation occurs when number of cards changes
            .ignoresSafeArea()
            .navigationTitle("Keşfet")
        }
    }
}

#Preview {
    ExploreView()
}
