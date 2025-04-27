import SwiftUI

struct RegisterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthService
    
    @State private var username = ""
    @State private var country  = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""
    @State private var selectedImage: UIImage?
    
    enum Step { case one, two }
    @State private var step: Step = .one
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                HStack {
                    Text("Hesap Oluştur")
                        .font(.title2.weight(.semibold))
                    
                    Spacer()
                    
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 38)
                
                switch step {
                case .one:
                    StepOneView(username: $username,
                                country:  $country,
                                email:    $email,
                                password: $password,
                                confirm:  $confirm) {
                        withAnimation { step = .two }
                    }
                    
                case .two:
                    StepTwoView(selectedImage: $selectedImage,
                                onBack: { withAnimation { step = .one } },
                                onComplete: {
                        Task {
                            do {
                                try await auth.register(
                                    username: username,
                                    country : country,
                                    email   : email,
                                    password: password,
                                    image   : selectedImage
                                )
                                dismiss()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    },
                                onSkip: { dismiss() })
                    Spacer(minLength: 0)
                }
            }
            .overlay {
                if auth.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Hesap oluşturuluyor...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}
