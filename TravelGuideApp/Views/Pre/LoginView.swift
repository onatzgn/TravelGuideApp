import SwiftUI

struct LoginView: View {
    @State private var email        = ""
    @State private var password     = ""
    @State private var showRegister = false
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Text("Giriş Yap")
                    .font(.largeTitle.bold())

                VStack(spacing: 16) {
                    IconTextField(icon: "person",
                                  placeholder: "Email",
                                  text: $email,
                                  type: .normal)
                    IconTextField(icon: "lock",
                                  placeholder: "Şifre",
                                  text: $password,
                                  type: .secure)
                }
                .padding(.horizontal)

                PrimaryButton("Giriş Yap") {
                    Task {
                        do {
                            try await auth.login(email: email, password: password)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding(.horizontal)

                Button {
                    showRegister = true
                } label: {
                    Text("Yeni misin?  **Hesap Oluştur**")
                        .font(.callout)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6).ignoresSafeArea())
            .sheet(isPresented: $showRegister) {
                RegisterSheetView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .overlay {
                if auth.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Giriş yapılıyor...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}

#Preview { LoginView() }
