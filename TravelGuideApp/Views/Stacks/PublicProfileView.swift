/*
import SwiftUI

struct PublicProfileView: View {
    let user: TGUser

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.main)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Color(UIColor.main)
                            .frame(height: 220)
                            .clipShape(BottomRoundedRectangle(radius: 36))

                        VStack(spacing: 8) {
                            Group {
                                if let urlString = user.photoURL, let url = URL(string: urlString), !urlString.isEmpty {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } else if phase.error != nil {
                                            Image("profilePhoto")
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                } else {
                                    Image("profilePhoto")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 5))

                            Text(user.username)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            Text(user.country)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            Text("Takip Et")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.black)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, -24)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Hatıra Paralar")
                        .font(.headline)
                    Text("-")
                        .foregroundColor(.secondary)

                    Text("Seyahat Günlükleri")
                        .font(.headline)
                    Text("-")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
    }
}
*/
