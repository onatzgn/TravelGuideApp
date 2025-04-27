import CoreML
import Vision
import UIKit

class ImageClassifier {
    // CoreML modelini ve Vision modelini tutan değişkenler
    private var mlModel: MLModel
    private var visionModel: VNCoreMLModel

    // Sınıf etiketlerini tutan değişken
    private var classLabels: [String] = []

    // Sabit (hardcoded) etiket listesi - fallback için
    private let hardcodedLabels = [
        "alman_cesmesi", "ayasofya", "bozdogan_kemeri", "cemberlitas",
        "dikilitas", "galata_kulesi", "kadikoy_boga_heykeli", "kiz_kulesi",
        "medusa", "ortakoy_cami", "sultanahmet", "taksim_cumhuriyet_aniti",
        "topkapi_sarayi", "yilanli_sutun"
    ]

    init() {
        do {
            // 1. MLModel'i yükle
            // Not: 'place_recognition_model_updated3' projenizdeki Core ML model sınıfının adı olmalı.
            let configuration = MLModelConfiguration() // Gerekirse konfigürasyon ayarları eklenebilir
            self.mlModel = try place_recognition_model_updated3(configuration: configuration).model

            // 2. Vision için VNCoreMLModel oluştur
            self.visionModel = try VNCoreMLModel(for: self.mlModel)

            // 3. Sınıf etiketlerini model açıklamasından almayı dene
            if let labels = self.mlModel.modelDescription.classLabels, !labels.isEmpty {
                 self.classLabels = labels.compactMap { $0 as? String }
                 print("✅ Etiketler model açıklamasından başarıyla alındı: \(self.classLabels.count) adet.")
            } else {
                 // Alınamazsa veya boşsa sabit listeyi kullan
                 print("⚠️ Model açıklamasında etiket bulunamadı veya boş, sabit liste kullanılıyor.")
                 self.classLabels = hardcodedLabels
            }

            // Etiket sayısı kontrolü (opsiyonel ama faydalı)
            if let outputDescription = self.mlModel.modelDescription.outputDescriptionsByName.first?.value,
               let shapeConstraint = outputDescription.multiArrayConstraint {
                let outputCount = shapeConstraint.shape.last?.intValue ?? 0
                if outputCount > 0 && outputCount != self.classLabels.count {
                     print("‼️ UYARI: Modelin çıkış boyutu (\(outputCount)) ile etiket sayısı (\(self.classLabels.count)) eşleşmiyor!")
                }
            }


        } catch {
            fatalError("❌ CoreML modeli yüklenemedi veya VNCoreMLModel oluşturulamadı: \(error.localizedDescription)")
        }
    }

    /// Verilen bir UIImage'i sınıflandırır ve sonucu completion handler ile döndürür.
    /// - Parameters:
    ///   - image: Sınıflandırılacak UIImage nesnesi.
    ///   - imageName: Hata ayıklama logları için görüntünün adı (opsiyonel).
    ///   - completion: Sonucu (tahmin edilen etiket, güven skoru) veya hata durumunu döndüren closure.
    func classify(image: UIImage, imageName: String = "Image", completion: @escaping (String, Double) -> Void) {
        print("📷 \(imageName): Sınıflandırma başlıyor...")

        // 1. Görüntüyü yeniden boyutlandır (Modele uygun hale getir)
        print("🔍 Görüntü yeniden boyutlandırılıyor (224x224)...")
        let resizedImage = image.stretchedTo(size: CGSize(width: 224, height: 224))

        // 2. UIImage'i CIImage'a dönüştür
        guard let ciImage = CIImage(image: resizedImage) else {
            print("❌ UIImage -> CIImage dönüşümü başarısız.")
            completion("Error: CIImage Conversion Failed", 0.0)
            return
        }

        // 3. VNCoreMLRequest oluştur
        print("📦 VNCoreMLRequest oluşturuluyor...")
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            // Zayıf referans kullanarak olası retain cycle'ı önle
             guard let self = self else { return }

            // Hata kontrolü
            if let error = error {
                print("❌ VNCoreMLRequest işlenirken hata oluştu: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Error: Request Failed", 0.0)
                }
                return
            }

            // Sonuçları işle
            self.processResults(for: request, completion: completion)
        }

        // İsteğe bağlı: Görüntü kırpma ve ölçekleme seçeneklerini Vision'a bırakmak için
        // request.imageCropAndScaleOption = .scaleFill // veya .centerCrop vs.

        // 4. VNImageRequestHandler oluştur ve isteği gerçekleştir
        print("🛠️ VNImageRequestHandler hazırlanıyor ve istek gönderiliyor...")
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: image.cgImagePropertyOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                print("🚀 Sınıflandırma isteği başarıyla gönderildi ve işleniyor...")
            } catch {
                print("❌ VNImageRequestHandler.perform sırasında hata oluştu: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Error: Handler Failed", 0.0)
                }
            }
        }
    }

    /// VNCoreMLRequest sonuçlarını işleyen yardımcı fonksiyon.
    private func processResults(for request: VNRequest, completion: @escaping (String, Double) -> Void) {
        // 1. VNClassificationObservation KONTROLÜ (En Olası Durum - Classifier olarak tanımlanmışsa)
        if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
            let rawConfidences = results.map { Double($0.confidence) }
            let maxConfidence = rawConfidences.max() ?? 0

            // Eğer confidence 1.0'dan büyükse bu değerler logit'tir → Softmax uygulanmamış demektir
            if maxConfidence > 1.0 {
                print("⚠️ Uyarı: VNClassificationObservation confidence > 1.0 — manuel softmax uygulanıyor...")

                // Softmax uygula
                let stabilized = rawConfidences.map { $0 - maxConfidence }
                let expValues = stabilized.map { exp($0) }
                let sumExp = expValues.reduce(0, +)
                let softmax = expValues.map { $0 / sumExp }

                print("🔍 Manuel Softmax Sonuçları:")
                for (index, score) in softmax.enumerated() {
                    print("  - \(results[index].identifier): \(String(format: "%.2f%%", score * 100))")
                }

                if let maxIndex = softmax.indices.max(by: { softmax[$0] < softmax[$1] }) {
                    let predictedLabel = results[maxIndex].identifier
                    let confidence = softmax[maxIndex]
                    print("✅ En iyi tahmin (Manuel Softmax): \(predictedLabel), Güven: \(String(format: "%.2f%%", confidence * 100))")
                    if confidence < 0.75 {
                        print("❗ Güven skoru %75'in altında. Tahmin geçersiz sayılıyor. (Güven: \(String(format: "%.2f%%", confidence * 100)))")
                        DispatchQueue.main.async {
                            completion("unknown", confidence)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(predictedLabel, confidence)
                        }
                    }
                } else {
                    print("❌ Manuel Softmax sonrası en iyi tahmin bulunamadı.")
                    DispatchQueue.main.async {
                        completion("Error: Softmax ArgMax Failed", 0.0)
                    }
                }

                return // Manuel softmax kullanıldı
            }

            // Softmax doğru şekilde uygulanmışsa doğrudan kullan
            print("✅ Sonuçlar VNClassificationObservation olarak alındı (Softmax CoreML tarafından uygulanmış).")
            let identifier = topResult.identifier
            let confidence = Double(topResult.confidence)

            print("🔍 Tüm Tahminler (CoreML'den gelen):")
            results.prefix(5).forEach { observation in
                print("  - \(observation.identifier): \(String(format: "%.2f%%", observation.confidence * 100))")
            }

            print("✅ En iyi tahmin: \(identifier), Güven: \(String(format: "%.2f%%", confidence * 100))")
            if confidence < 0.75 {
                print("❗ Güven skoru %75'in altında. Tahmin geçersiz sayılıyor. (Güven: \(String(format: "%.2f%%", confidence * 100)))")
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

        // 2. VNCoreMLFeatureValueObservation KONTROLÜ (Fallback - Genel model çıkışı veya classifier olmayan durumlar)
        if let results = request.results as? [VNCoreMLFeatureValueObservation],
           let multiArray = results.first?.featureValue.multiArrayValue {
            print("⚠️ VNClassificationObservation alınamadı, VNCoreMLFeatureValueObservation ile manuel Softmax yapılıyor...")

            // MLMultiArray'den Float dizisine dönüştür
            guard let pointer = try? UnsafeBufferPointer<Float32>(multiArray) else {
                print("❌ MLMultiArray verisi Float32 dizisine dönüştürülemedi.")
                DispatchQueue.main.async { completion("Error: MultiArray Conversion", 0.0) }
                return
            }
            let floatArray = Array(pointer) // Ham çıkışlar (logits)

             // Etiket sayısı ile çıkış sayısı kontrolü
             if self.classLabels.count != floatArray.count {
                 print("❌ Etiket sayısı (\(self.classLabels.count)) ile model çıkış sayısı (\(floatArray.count)) eşleşmiyor!")
                 // Modelin son katmanını veya etiket listesini kontrol edin.
                 // En iyi ihtimalle devam etmeyi deneyebiliriz ama muhtemelen yanlış sonuç verir.
                 // completion("Error: Label/Output Mismatch", 0.0)
                 // return // Veya riski alıp devam et
             }

            // ---- Manuel Softmax Uygulaması ----
            // Stabilize etmek için en büyük logit'i çıkar (sayısal stabilite için)
            let maxLogit = floatArray.max() ?? 0
            let stabilized = floatArray.map { $0 - maxLogit }
            // Üstel değerleri hesapla
            let expValues = stabilized.map { expf($0) }
            // Üstel değerlerin toplamını hesapla
            let sumExp = expValues.reduce(0, +)
            // Softmax olasılıklarını hesapla (eğer toplam 0 değilse)
            let softmax = sumExp > 0 ? expValues.map { $0 / sumExp } : Array(repeating: 1.0 / Float(expValues.count), count: expValues.count) // Toplam 0 ise eşit dağıt
            // ---- Manuel Softmax Sonu ----


            print("🔍 Manuel Softmax Sonuçları:")
            for (index, score) in softmax.enumerated() {
                // Güvenlik kontrolü: index'in labels dizisinin sınırları içinde olduğundan emin ol
                if index < self.classLabels.count {
                    print("  - \(self.classLabels[index]): \(String(format: "%.2f%%", score * 100))")
                } else {
                    print("  - Index \(index) etiket listesi sınırları dışında!")
                }
            }

            // En yüksek olasılığa sahip indeksi ve etiketi bul
            if let maxIndex = softmax.indices.max(by: { softmax[$0] < softmax[$1] }), maxIndex < self.classLabels.count { // Sınır kontrolü ekle
                let predictedLabel = self.classLabels[maxIndex]
                let confidence = softmax[maxIndex]
                print("✅ En iyi tahmin (Manuel Softmax): \(predictedLabel), Güven: \(String(format: "%.2f%%", confidence * 100))")
                if confidence < 0.75 {
                    print("❗ Güven skoru %75'in altında. Tahmin geçersiz sayılıyor. (Güven: \(String(format: "%.2f%%", confidence * 100)))")
                    DispatchQueue.main.async {
                        completion("unknown", Double(confidence))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(predictedLabel, Double(confidence))
                    }
                }
            } else {
                print("❌ Manuel Softmax sonrası en iyi tahmin bulunamadı veya index sınır dışında.")
                DispatchQueue.main.async { completion("Error: Softmax ArgMax Failed", 0.0) }
            }
            return // İşlem tamamlandı
        }

        // HİÇBİR UYGUN SONUÇ FORMATI ALINAMAZSA
        print("❌ VNCoreMLRequest beklenen formatta sonuç döndürmedi (Ne VNClassificationObservation ne de VNCoreMLFeatureValueObservation). Modelin çıktılarını kontrol edin.")
        DispatchQueue.main.async {
            completion("Error: No Valid Results", 0.0)
        }
    }

    // Hata ayıklama için piksel analizi fonksiyonu (isteğe bağlı)
    private func analyzeImagePixels(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("❌ CGImage alınamadı")
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        // Bu kısım genellikle Core ML'in otomatik yaptığı ön işlemeyi manuel olarak simüle etmek içindir.
        // Modelin ct.ImageType içinde tanımlanan scale ve bias ile ön işleme yapması beklenir.
        // Bu fonksiyon sadece bilgi amaçlıdır, modelin asıl girdisini etkilemez.
        print("🔬 Piksel Analizi (Bilgi Amaçlı): \(width)x\(height)")
        // ... (Önceki kodunuzdaki piksel okuma ve ortalama hesaplama kısmı buraya eklenebilir) ...
    }
}

// MARK: - UIImage Extensions

extension UIImage {
    /// UIImage'in yönelimini Vision framework'ünün anlayacağı CGImagePropertyOrientation'a çevirir.
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
            print("⚠️ Bilinmeyen UIImage.Orientation değeri, varsayılan olarak .up kullanılıyor.")
            return .up
        }
    }

    /// UIImage'i belirtilen boyuta, en/boy oranını korumadan esneterek yeniden boyutlandırır.
    /// - Parameter targetSize: Hedef boyut (CGSize).
    /// - Returns: Yeniden boyutlandırılmış UIImage veya işlem başarısız olursa orijinal görüntü.
    func stretchedTo(size targetSize: CGSize) -> UIImage {
        // UIGraphicsBeginImageContextWithOptions genellikle daha iyi kalite sunar.
        // opaque: false -> Alfa kanalını koru
        // scale: self.scale -> Retina ekranlarda pikselleşmeyi önle (veya model 1x bekliyorsa 1.0)
        // Modelinizin 224x224@1x beklediğini varsayarsak scale: 1.0 daha doğru olabilir.
        // Emin değilseniz self.scale kullanmak genellikle güvenlidir.
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0) // scale'i 1.0 olarak değiştirdim.
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self // Başarısız olursa orijinali döndür
    }
}
