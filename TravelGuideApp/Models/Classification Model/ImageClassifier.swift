import CoreML
import Vision
import UIKit

class ImageClassifier {
    // coreml modelini ve vision modelini tutan değişkenler
    private var mlModel: MLModel
    private var visionModel: VNCoreMLModel

    // sınıf etiketlerini tutan değişken
    private var classLabels: [String] = []

    private let hardcodedLabels = [
        "alman_cesmesi", "ayasofya", "bozdogan_kemeri", "cemberlitas",
        "dikilitas", "galata_kulesi", "kadikoy_boga_heykeli", "kiz_kulesi",
        "medusa", "ortakoy_cami", "sultanahmet", "taksim_cumhuriyet_aniti",
        "topkapi_sarayi", "yilanli_sutun"
    ]

    init() {
        do {
            let configuration = MLModelConfiguration()
            self.mlModel = try place_recognition_model_updated3(configuration: configuration).model

            // v ision için vncoreml
            self.visionModel = try VNCoreMLModel(for: self.mlModel)

            // sınıf etiketlerini model açıklamasından almayı denedim
            if let labels = self.mlModel.modelDescription.classLabels, !labels.isEmpty {
                 self.classLabels = labels.compactMap { $0 as? String }
                 print(" Etiketler model açıklamasından başarıyla alındı: \(self.classLabels.count) adet.")
            } else {
                 // alınamazsa veya boşsa yuardaki sabit listeyi kullandım
                 print(" Model açıklamasında etiket bulunamadı veya boş, sabit liste kullanılıyor.")
                 self.classLabels = hardcodedLabels
            }

            if let outputDescription = self.mlModel.modelDescription.outputDescriptionsByName.first?.value,
               let shapeConstraint = outputDescription.multiArrayConstraint {
                let outputCount = shapeConstraint.shape.last?.intValue ?? 0
                if outputCount > 0 && outputCount != self.classLabels.count {
                     print(" UYARI: Modelin çıkış boyutu (\(outputCount)) ile etiket sayısı (\(self.classLabels.count)) eşleşmiyor!")
                }
            }


        } catch {
            fatalError("❌ CoreML modeli yüklenemedi veya VNCoreMLModel oluşturulamadı: \(error.localizedDescription)")
        }
    }

    // verilen bir uiimage'i sınıflandırır ve sonucu completion handler ile döndürür.
    // Parameters:
    //   image: sınıflandırılacak uiim nesnesi.
    //   imageName: hata ayıklama logları için görüntünün adı
    //   completion: sonucu veya hata durumunu döndüren closure.
    func classify(image: UIImage, imageName: String = "Image", completion: @escaping (String, Double) -> Void) {
        print("\(imageName): Sınıflandırma başlıyor...")

        print(" Görüntü yeniden boyutlandırılıyor (224x224)...")
        let resizedImage = image.stretchedTo(size: CGSize(width: 224, height: 224))

        // uuim ciim
        guard let ciImage = CIImage(image: resizedImage) else {
            print(" UIImage -> CIImage dönüşümü başarısız.")
            completion("Error: CIImage Conversion Failed", 0.0)
            return
        }

        // vncoremlreq
        print(" VNCoreMLRequest oluşturuluyor...")
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
             guard let self = self else { return }

            if let error = error {
                print(" VNCoreMLRequest işlenirken hata oluştu: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Error: Request Failed", 0.0)
                }
                return
            }

            self.processResults(for: request, completion: completion)
        }


        // vnmimreqhandler oluşturduk
        print(" VNImageRequestHandler hazırlanıyor ve istek gönderiliyor...")
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: image.cgImagePropertyOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                print(" Sınıflandırma isteği başarıyla gönderildi ve işleniyor...")
            } catch {
                print(" VNImageRequestHandler.perform sırasında hata oluştu: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Error: Handler Failed", 0.0)
                }
            }
        }
    }

    // vncorereq sonuçlarını işleyen yardımcı fonksiyon
    private func processResults(for request: VNRequest, completion: @escaping (String, Double) -> Void) {
        // vNClassificationObservation KONTROL
        if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
            let rawConfidences = results.map { Double($0.confidence) }
            let maxConfidence = rawConfidences.max() ?? 0

            // softmax uygula önce şarta bak
            if maxConfidence > 1.0 {
                print(" Uyarı: VNClassificationObservation confidence > 1.0 — manuel softmax uygulanıyor...")

                // softmax uygula
                let stabilized = rawConfidences.map { $0 - maxConfidence }
                let expValues = stabilized.map { exp($0) }
                let sumExp = expValues.reduce(0, +)
                let softmax = expValues.map { $0 / sumExp }

                print(" Manuel Softmax Sonuçları:")
                for (index, score) in softmax.enumerated() {
                    print("  - \(results[index].identifier): \(String(format: "%.2f%%", score * 100))")
                }

                if let maxIndex = softmax.indices.max(by: { softmax[$0] < softmax[$1] }) {
                    let predictedLabel = results[maxIndex].identifier
                    let confidence = softmax[maxIndex]
                    print("En iyi tahmin (Manuel Softmax): \(predictedLabel), Güven: \(String(format: "%.2f%%", confidence * 100))")
                    if confidence < 0.75 {
                        print(" Güven skoru %75'in altında. Tahmin geçersiz sayılıyor. (Güven: \(String(format: "%.2f%%", confidence * 100)))")
                        DispatchQueue.main.async {
                            completion("unknown", confidence)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(predictedLabel, confidence)
                        }
                    }
                } else {
                    print(" Manuel Softmax sonrası en iyi tahmin bulunamadı.")
                    DispatchQueue.main.async {
                        completion("Error: Softmax ArgMax Failed", 0.0)
                    }
                }

                return
            }

            // softax varsa
            print(" Sonuçlar VNClassificationObservation olarak alındı (Softmax CoreML tarafından uygulanmış).")
            let identifier = topResult.identifier
            let confidence = Double(topResult.confidence)

            print(" Tüm Tahminler (CoreML'den gelen):")
            results.prefix(5).forEach { observation in
                print("  - \(observation.identifier): \(String(format: "%.2f%%", observation.confidence * 100))")
            }

            print("En iyi tahmin: \(identifier), Güven: \(String(format: "%.2f%%", confidence * 100))")
            if confidence < 0.75 {
                print(" Güven skoru %75'in altında. Tahmin geçersiz sayılıyor. (Güven: \(String(format: "%.2f%%", confidence * 100)))")
                DispatchQueue.main.async {
                    completion("unknown", confidence)
                }
            } else {
                DispatchQueue.main.async {
                    completion(identifier, confidence)
                }
            }
            return
        }

        //  VNCoreMLFeatureValueObservation KONTROLÜ (fallback - genel model çıkışı veya classifier olmayan durumlar)
        if let results = request.results as? [VNCoreMLFeatureValueObservation],
           let multiArray = results.first?.featureValue.multiArrayValue {
            print("VNClassificationObservation alınamadı, VNCoreMLFeatureValueObservation ile manuel Softmax yapılıyor...")

            guard let pointer = try? UnsafeBufferPointer<Float32>(multiArray) else {
                print(" MLMultiArray verisi Float32 dizisine dönüştürülemedi.")
                DispatchQueue.main.async { completion("Error: MultiArray Conversion", 0.0) }
                return
            }
            let floatArray = Array(pointer) // logits

             // etiket sayısı ile çıkış sayısı kontrolümü
             if self.classLabels.count != floatArray.count {
                 print(" Etiket sayısı (\(self.classLabels.count)) ile model çıkış sayısı (\(floatArray.count)) eşleşmiyor!")
             }

            // ---- manuel softmaz   ----
            let maxLogit = floatArray.max() ?? 0
            let stabilized = floatArray.map { $0 - maxLogit }
            let expValues = stabilized.map { expf($0) }
            let sumExp = expValues.reduce(0, +)
            let softmax = sumExp > 0 ? expValues.map { $0 / sumExp } : Array(repeating: 1.0 / Float(expValues.count), count: expValues.count)


            print(" Manuel Softmax Sonuçları:")
            for (index, score) in softmax.enumerated() {
                if index < self.classLabels.count {
                    print("  - \(self.classLabels[index]): \(String(format: "%.2f%%", score * 100))")
                } else {
                    print("  - Index \(index) etiket listesi sınırları dışında!")
                }
            }

            if let maxIndex = softmax.indices.max(by: { softmax[$0] < softmax[$1] }), maxIndex < self.classLabels.count {
                let predictedLabel = self.classLabels[maxIndex]
                let confidence = softmax[maxIndex]
                print(" En iyi tahmin (Manuel Softmax): \(predictedLabel), Güven: \(String(format: "%.2f%%", confidence * 100))")
                if confidence < 0.75 {
                    print(" Güven skoru %75'in altında. Tahmin geçersiz sayılıyor. (Güven: \(String(format: "%.2f%%", confidence * 100)))")
                    DispatchQueue.main.async {
                        completion("unknown", Double(confidence))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(predictedLabel, Double(confidence))
                    }
                }
            } else {
                print(" Manuel Softmax sonrası en iyi tahmin bulunamadı veya index sınır dışında.")
                DispatchQueue.main.async { completion("Error: Softmax ArgMax Failed", 0.0) }
            }
            return
        }

        print(" VNCoreMLRequest beklenen formatta sonuç döndürmedi (Ne VNClassificationObservation ne de VNCoreMLFeatureValueObservation). Modelin çıktılarını kontrol edin.")
        DispatchQueue.main.async {
            completion("Error: No Valid Results", 0.0)
        }
    }

    private func analyzeImagePixels(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            print(" CGImage alınamadı")
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        print(" Piksel Analizi (Bilgi Amaçlı): \(width)x\(height)")
    }
}

// MARK: - uiimage extensions

extension UIImage {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:
            print(" Bilinmeyen UIImage.Orientation değeri, varsayılan olarak .up kullanılıyor.")
            return .up
        }
    }

    func stretchedTo(size targetSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
