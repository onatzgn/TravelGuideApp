import SwiftUI

struct PrimaryButton: View {
    let title: String
    let showChevron: Bool
    let action: () -> Void

    init(_ title: String, showChevron: Bool = true, action: @escaping () -> Void) {
        self.title      = title
        self.showChevron = showChevron
        self.action     = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.main))      
            )
        }
    }
}
