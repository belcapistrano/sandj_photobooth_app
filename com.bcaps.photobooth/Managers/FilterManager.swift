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
        case .original:
            return image
        case .warmRomance:
            filteredImage = applyWarmRomanceFilter(to: ciImage)
        case .classicFilm:
            filteredImage = applyClassicFilmFilter(to: ciImage)
        case .elegantBW:
            filteredImage = applyElegantBWFilter(to: ciImage)
        case .softDream:
            filteredImage = applySoftDreamFilter(to: ciImage)
        }

        guard let finalImage = filteredImage,
              let cgImage = context.createCGImage(finalImage, from: finalImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - Wedding Filter Implementations

    private func applyWarmRomanceFilter(to image: CIImage) -> CIImage? {
        guard let temperatureFilter = CIFilter(name: "CITemperatureAndTint"),
              let saturationFilter = CIFilter(name: "CIColorControls") else { return nil }

        // Apply warm temperature adjustment
        temperatureFilter.setValue(image, forKey: kCIInputImageKey)
        temperatureFilter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
        temperatureFilter.setValue(CIVector(x: 4500, y: 50), forKey: "inputTargetNeutral")

        guard let temperatureOutput = temperatureFilter.outputImage else { return nil }

        // Boost saturation slightly for romantic effect
        saturationFilter.setValue(temperatureOutput, forKey: kCIInputImageKey)
        saturationFilter.setValue(1.15, forKey: kCIInputSaturationKey)
        saturationFilter.setValue(1.05, forKey: kCIInputBrightnessKey)

        return saturationFilter.outputImage
    }

    private func applyClassicFilmFilter(to image: CIImage) -> CIImage? {
        guard let colorFilter = CIFilter(name: "CIColorControls"),
              let vignetteFilter = CIFilter(name: "CIVignette") else { return nil }

        // Apply film-like color adjustments
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(0.92, forKey: kCIInputSaturationKey) // Slight desaturation
        colorFilter.setValue(1.08, forKey: kCIInputContrastKey) // Soft contrast
        colorFilter.setValue(1.02, forKey: kCIInputBrightnessKey) // Slightly brighter

        guard let colorOutput = colorFilter.outputImage else { return nil }

        // Add subtle vignette for film effect
        vignetteFilter.setValue(colorOutput, forKey: kCIInputImageKey)
        vignetteFilter.setValue(0.6, forKey: kCIInputIntensityKey)
        vignetteFilter.setValue(2.5, forKey: kCIInputRadiusKey)

        return vignetteFilter.outputImage
    }

    private func applyElegantBWFilter(to image: CIImage) -> CIImage? {
        guard let bwFilter = CIFilter(name: "CIPhotoEffectMono"),
              let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }

        // Convert to elegant black and white
        bwFilter.setValue(image, forKey: kCIInputImageKey)

        guard let bwOutput = bwFilter.outputImage else { return nil }

        // Enhance contrast for sophistication
        contrastFilter.setValue(bwOutput, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.2, forKey: kCIInputContrastKey)
        contrastFilter.setValue(1.05, forKey: kCIInputBrightnessKey)

        return contrastFilter.outputImage
    }

    private func applySoftDreamFilter(to image: CIImage) -> CIImage? {
        guard let blurFilter = CIFilter(name: "CIGaussianBlur"),
              let blendFilter = CIFilter(name: "CISourceOverCompositing"),
              let brightnessFilter = CIFilter(name: "CIColorControls") else { return nil }

        // Create soft blur effect
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(1.5, forKey: kCIInputRadiusKey)

        guard let blurOutput = blurFilter.outputImage else { return nil }

        // Brighten and soften the image
        brightnessFilter.setValue(image, forKey: kCIInputImageKey)
        brightnessFilter.setValue(1.08, forKey: kCIInputBrightnessKey)
        brightnessFilter.setValue(1.1, forKey: kCIInputSaturationKey)

        guard let brightnessOutput = brightnessFilter.outputImage else { return nil }

        // Blend original with soft blur for dreamy effect
        blendFilter.setValue(blurOutput, forKey: kCIInputImageKey)
        blendFilter.setValue(brightnessOutput, forKey: kCIInputBackgroundImageKey)

        return blendFilter.outputImage
    }

    func getAllFilters() -> [FilterType] {
        return FilterType.allCases
    }

    func getFilterPreview(_ filterType: FilterType, for image: UIImage, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        let resizedImage = image.resized(to: size)
        return applyFilter(filterType, to: resizedImage)
    }

    // MARK: - Real-Time Filter Support

    func applyFilterToPixelBuffer(_ filterType: FilterType, to pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        guard filterType != .original else { return pixelBuffer }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        var filteredImage: CIImage?

        switch filterType {
        case .original:
            return pixelBuffer
        case .warmRomance:
            filteredImage = applyWarmRomanceFilter(to: ciImage)
        case .classicFilm:
            filteredImage = applyClassicFilmFilter(to: ciImage)
        case .elegantBW:
            filteredImage = applyElegantBWFilter(to: ciImage)
        case .softDream:
            filteredImage = applySoftDreamFilter(to: ciImage)
        }

        guard let finalImage = filteredImage else { return pixelBuffer }

        // Create output pixel buffer
        var outputPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            CVPixelBufferGetWidth(pixelBuffer),
            CVPixelBufferGetHeight(pixelBuffer),
            CVPixelBufferGetPixelFormatType(pixelBuffer),
            nil,
            &outputPixelBuffer
        )

        guard status == kCVReturnSuccess,
              let outputBuffer = outputPixelBuffer else { return pixelBuffer }

        context.render(finalImage, to: outputBuffer)
        return outputBuffer
    }

    // MARK: - Filter Thumbnail Generation

    func createFilterThumbnail(_ filterType: FilterType, baseImage: UIImage = UIImage(systemName: "camera")!) -> UIImage? {
        let thumbnailSize = CGSize(width: 60, height: 60)

        // Create a sample image if no base image provided
        let sampleImage: UIImage
        if baseImage.size == CGSize(width: 0, height: 0) {
            // Create a simple gradient as sample
            sampleImage = createSampleThumbnailImage(size: thumbnailSize)
        } else {
            sampleImage = baseImage.resized(to: thumbnailSize)
        }

        return applyFilter(filterType, to: sampleImage)
    }

    private func createSampleThumbnailImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Create a simple gradient for filter preview
            let colors = [UIColor.lightGray.cgColor, UIColor.darkGray.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!

            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint.zero,
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
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