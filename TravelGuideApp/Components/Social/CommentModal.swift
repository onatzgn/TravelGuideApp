import SwiftUI

struct CommentModal: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthService
    let placeLabel: String
    var onComplete: (() -> Void)?
    
    @State private var commentText = ""
    @State private var sending = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $commentText)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.4)))
                    .padding()
                Spacer()
            }
            .navigationTitle("Yorum Yaz")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Paylaş") {
                        Task {
                            sending = true
                            try? await auth.addComment(place: placeLabel,
                                                       text: commentText)
                            sending = false
                            onComplete?()
                            dismiss()
                        }
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sending)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
