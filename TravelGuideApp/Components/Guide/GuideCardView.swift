import SwiftUI
import FirebaseAuth

struct GuideCardView: View {
    let guide: GuideSummary
    var onTap: () -> Void
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 0
    @State private var isSaved: Bool = false

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    AsyncImage(url: URL(string: guide.coverURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(3/2, contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(12)

      
                    Text(guide.title)
                        .font(.headline)
                        .lineLimit(1)

                
                    Text(guide.description)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.secondary)

         
                    HStack(spacing: 8) {
                        if let url = guide.userPhotoURL,
                           let imageURL = URL(string: url) {
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        }

                        Text(guide.username)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    Text("\(likeCount) Beğeni")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 8) {
                    Button(action: {
                        Task {
                            if isSaved {
                                await AuthService.shared.unsaveGuide(guide)
                                isSaved = false
                            } else {
                                await AuthService.shared.saveGuide(guide)
                                isSaved = true
                            }
                        }
                    }) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 1)
                    }

                    Button(action: {
                        Task {
                            if isLiked {
                                await AuthService.shared.unlikeGuide(guide: guide, by: AuthService.shared.user?.id ?? "")
                                likeCount -= 1
                                isLiked = false
                            } else {
                                await AuthService.shared.likeGuide(guide: guide, by: AuthService.shared.user?.id ?? "")
                                likeCount += 1
                                isLiked = true
                            }
                        }
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isLiked ? .red : .black)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 1)
                    }
                }
                .padding(8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .task {
            await loadState()
        }
    }

    private func loadState() async {
        guard let userId = AuthService.shared.user?.id else { return }
        isLiked = await AuthService.shared.hasLikedGuide(guide)
        likeCount = await AuthService.shared.fetchLikeCount(for: guide)
        isSaved  = await AuthService.shared.hasSavedGuide(guide)   
    }
}
