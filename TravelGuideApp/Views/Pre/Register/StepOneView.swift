import SwiftUI

struct StepOneView: View {
    @Binding var username: String
    @Binding var country:  String
    @Binding var email:    String
    @Binding var password: String
    @Binding var confirm:  String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            IconTextField(icon: "person",   placeholder: "Kullanıcı Adı",   text: $username, type: .normal)
            IconTextField(icon: "flag",     placeholder: "Ülke",            text: $country,  type: .normal)
            IconTextField(icon: "envelope", placeholder: "Mail",            text: $email,    type: .normal)
            IconTextField(icon: "lock",     placeholder: "Şifre",           text: $password, type: .secure)
            IconTextField(icon: "lock",     placeholder: "Şifreyi Doğrula", text: $confirm,  type: .secure)

            PrimaryButton("Devam Et") { onNext() }
                .padding(.top, 12)
        }
        .padding(.horizontal)
    }
}
