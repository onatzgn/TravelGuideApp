/*
import Foundation
import UIKit

class BatchImageTester {
    private let classifier = ImageClassifier()
    
    func evaluateDataset(at folderURL: URL) {
        let fileManager = FileManager.default
        guard let classFolders = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
            print(" Sınıf klasörleri okunamadı.")
            return
        }

        var total = 0
        var correct = 0
        let dispatchGroup = DispatchGroup()

        for classFolder in classFolders where classFolder.hasDirectoryPath {
            let className = classFolder.lastPathComponent

            guard let imageFiles = try? fileManager.contentsOfDirectory(at: classFolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
                continue
            }

            for imageURL in imageFiles where ["jpg", "png"].contains(imageURL.pathExtension.lowercased()) {
                guard let image = UIImage(contentsOfFile: imageURL.path) else {
                    print(" Görsel yüklenemedi: \(imageURL.lastPathComponent)")
                    continue
                }

                let resizedImage = image.stretchedTo(size: CGSize(width: 224, height: 224))
                dispatchGroup.enter()

                classifier.classify(image: resizedImage, imageName: imageURL.lastPathComponent) { predicted, _ in
                    total += 1
                    let result = predicted == className
                    if result { correct += 1 }

                    print(" \(imageURL.lastPathComponent): Tahmin = \(predicted), Gerçek = \(className) \(result ? "true" : "false")")
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            let accuracy = Double(correct) / Double(total)
            print(" Doğru: \(correct) / \(total)")
            print(" Accuracy: \(String(format: "%.2f", accuracy * 100))%")
        }
    }
}
*/
