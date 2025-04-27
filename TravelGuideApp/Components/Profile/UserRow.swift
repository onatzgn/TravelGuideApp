import SwiftUI

struct UserRow: View {
    let user: TGUser
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileImageView(photoURL: user.photoURL, size: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.headline)
                
                Text(user.country)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    UserRow(user: TGUser(id: "1",
                         username: "DemoUser",
                         country: "Türkiye",
                         email: "demo@demo.com",
                         photoURL: nil))
}
