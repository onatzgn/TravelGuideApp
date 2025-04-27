import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Mekan ara...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled(true)
        }
        .padding(10)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}
