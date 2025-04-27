/*
import SwiftUI

struct UserSearchRow: View {
    let user: TGUser

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.photoURL ?? "")) { phase in
                Group {
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image("profilePhoto")
                            .resizable()
                            .scaledToFill()
                    default:
                        Image("profilePhoto")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .transaction { $0.animation = nil }
            } // Closing brace added here

            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.headline)
                Text(user.country)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("Takip Et")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(UIColor.main))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}
*/
/*
import SwiftUI

struct UserSearchRow: View {
    let user: TGUser

    @EnvironmentObject private var auth: AuthService

    var body: some View {
        HStack {
            ProfileImageView(size: 48)
                .environmentObject(auth)
                .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.headline)
                Text(user.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                // Şimdilik sadece placeholder
                print("Takip Et: \(user.username)")
            }) {
                Text("Takip Et")
                    .font(.subheadline.weight(.medium))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}
*/
