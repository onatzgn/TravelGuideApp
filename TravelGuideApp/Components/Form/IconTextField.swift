import SwiftUI

struct IconTextField: View {
    enum FieldType { case normal, secure }

    let icon: String
    let placeholder: String
    @Binding var text: String
    let type: FieldType

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)

            if type == .secure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.black)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.black)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}
