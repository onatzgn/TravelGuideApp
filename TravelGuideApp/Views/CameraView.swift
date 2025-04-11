import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera    // Kamera kullanımını seçiyoruz
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    // iOS’in UIImagePickerControllerDelegate ve UINavigationControllerDelegate protokollerini yönetmesi için:
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        // Kullanıcı “İptal” butonuna basarsa
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        // Fotoğraf çekilip onaylandığında
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // info içinden çekilen görüntüye erişebilirsin (örneğin let image = info[.originalImage] as? UIImage)
            // İstediğin işlemi yapabilirsin

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ExploreView()
}
