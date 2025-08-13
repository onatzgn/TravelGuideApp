import SwiftUI

struct AvatarView: View {
    var url: URL?
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let url {                // real asynchronous image
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable()
                    default:               Image("avatar_placeholder")
                                                .resizable()
                    }
                }
            } else {
                Image("avatar_placeholder")
                    .resizable()
            }
        }
        .scaledToFill()
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
