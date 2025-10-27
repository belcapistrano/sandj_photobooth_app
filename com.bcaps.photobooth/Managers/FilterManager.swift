import UIKit
import CoreImage

class FilterManager {

    static let shared = FilterManager()

    private let context = CIContext()

    private init() {}

    func applyFilter(_ filterType: FilterType, to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }

        var filteredImage: CIImage?

        switch filterType {
        case .none:
            return image
        case .vintage:
            filteredImage = applyVintageFilter(to: ciImage)
        case .blackAndWhite:
            filteredImage = applyBlackAndWhiteFilter(to: ciImage)
        case .sepia:
            filteredImage = applySepiaFilter(to: ciImage)
        case .vibrant:
            filteredImage = applyVibrantFilter(to: ciImage)
        case .dramatic:
            filteredImage = applyDramaticFilter(to: ciImage)
        case .cool:
            filteredImage = applyCoolFilter(to: ciImage)
        case .warm:
            filteredImage = applyWarmFilter(to: ciImage)
        }

        guard let finalImage = filteredImage,
              let cgImage = context.createCGImage(finalImage, from: finalImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage)
    }

    private func applyVintageFilter(to image: CIImage) -> CIImage? {
        guard let sepiaFilter = CIFilter(name: "CISepiaTone"),
              let vignetteFilter = CIFilter(name: "CIVignette") else { return nil }

        sepiaFilter.setValue(image, forKey: kCIInputImageKey)
        sepiaFilter.setValue(0.8, forKey: kCIInputIntensityKey)

        guard let sepiaOutput = sepiaFilter.outputImage else { return nil }

        vignetteFilter.setValue(sepiaOutput, forKey: kCIInputImageKey)
        vignetteFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        vignetteFilter.setValue(1.5, forKey: kCIInputRadiusKey)

        return vignetteFilter.outputImage
    }

    private func applyBlackAndWhiteFilter(to image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIColorMonochrome") else { return nil }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIColor.gray, forKey: kCIInputColorKey)
        filter.setValue(1.0, forKey: kCIInputIntensityKey)

        return filter.outputImage
    }

    private func applySepiaFilter(to image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: kCIInputIntensityKey)

        return filter.outputImage
    }

    private func applyVibrantFilter(to image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIVibrancy") else { return nil }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.5, forKey: kCIInputAmountKey)

        return filter.outputImage
    }

    private func applyDramaticFilter(to image: CIImage) -> CIImage? {
        guard let contrastFilter = CIFilter(name: "CIColorControls"),
              let vignetteFilter = CIFilter(name: "CIVignette") else { return nil }

        contrastFilter.setValue(image, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.2, forKey: kCIInputContrastKey)
        contrastFilter.setValue(0.1, forKey: kCIInputBrightnessKey)
        contrastFilter.setValue(1.1, forKey: kCIInputSaturationKey)

        guard let contrastOutput = contrastFilter.outputImage else { return nil }

        vignetteFilter.setValue(contrastOutput, forKey: kCIInputImageKey)
        vignetteFilter.setValue(0.8, forKey: kCIInputIntensityKey)
        vignetteFilter.setValue(2.0, forKey: kCIInputRadiusKey)

        return vignetteFilter.outputImage
    }

    private func applyCoolFilter(to image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CITemperatureAndTint") else { return nil }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 4000, y: 0), forKey: "inputNeutral")
        filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral")

        return filter.outputImage
    }

    private func applyWarmFilter(to image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CITemperatureAndTint") else { return nil }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
        filter.setValue(CIVector(x: 4000, y: 0), forKey: "inputTargetNeutral")

        return filter.outputImage
    }

    func getAllFilters() -> [FilterType] {
        return FilterType.allCases
    }

    func getFilterPreview(_ filterType: FilterType, for image: UIImage, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        let resizedImage = image.resized(to: size)
        return applyFilter(filterType, to: resizedImage)
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}