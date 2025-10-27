import UIKit
import CoreGraphics

class PhotoStripComposer {

    static let shared = PhotoStripComposer()

    // Wedding customization
    var coupleNames: String = "Shahnila & Josh"
    var weddingDate: String = ""
    var isWeddingTheme: Bool = true
    var eventHashtag: String = "#ShahnilaAndJoshWedding"

    private init() {
        // Set default wedding date to today if not specified
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        weddingDate = formatter.string(from: Date())
    }

    func createPhotoStrip(from photos: [UIImage], layout: LayoutTemplate? = nil) -> UIImage? {
        guard !photos.isEmpty else { return nil }

        // Always use photo strip layout - check for wedding theme first
        if isWeddingTheme {
            return createWeddingLayout(photos: photos)
        } else {
            return createStripLayout(photos: photos)
        }
    }

    // MARK: - Wedding Layout

    private func createWeddingLayout(photos: [UIImage]) -> UIImage? {
        let photoCount = min(photos.count, 3)
        guard photoCount > 0 else { return nil }

        let stripWidth: CGFloat = 400
        let photoHeight: CGFloat = 260
        let spacing: CGFloat = 20
        let headerHeight: CGFloat = 60
        let footerHeight: CGFloat = 80
        let borderWidth: CGFloat = 40
        let textSectionHeight: CGFloat = 80

        let totalHeight = headerHeight + (CGFloat(photoCount) * photoHeight) + (CGFloat(photoCount - 1) * spacing) + textSectionHeight + spacing + footerHeight + (2 * borderWidth)
        let finalSize = CGSize(width: stripWidth, height: totalHeight)

        UIGraphicsBeginImageContextWithOptions(finalSize, true, 0)
        defer { UIGraphicsEndImageContext() }

        // Clean white background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: finalSize))

        // Simple header with couple names
        addSimpleWeddingHeader(to: finalSize, headerHeight: headerHeight)

        // Draw photos with elegant frames
        for (index, photo) in photos.prefix(photoCount).enumerated() {
            let y = headerHeight + borderWidth + (CGFloat(index) * (photoHeight + spacing))
            let photoRect = CGRect(
                x: borderWidth,
                y: y,
                width: stripWidth - (2 * borderWidth),
                height: photoHeight
            )

            // Draw photo to fill the entire frame
            drawPhotoToFillRect(photo, in: photoRect)

            // Add minimal photo border
            addMinimalBorder(to: photoRect)
        }

        // Add text section where 4th photo would be
        let textSectionY = headerHeight + borderWidth + (CGFloat(photoCount) * (photoHeight + spacing))
        let textSectionRect = CGRect(
            x: borderWidth,
            y: textSectionY,
            width: stripWidth - (2 * borderWidth),
            height: textSectionHeight
        )
        addSimpleWeddingTextSection(to: textSectionRect)

        // Simple footer
        addSimpleWeddingFooter(to: finalSize, footerHeight: footerHeight)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - Layout Methods

    private func createSingleLayout(photos: [UIImage]) -> UIImage? {
        guard let firstPhoto = photos.first else { return nil }

        let targetSize = CGSize(width: 600, height: 800)
        let finalSize = CGSize(width: 700, height: 900)

        UIGraphicsBeginImageContextWithOptions(finalSize, true, 0)
        defer { UIGraphicsEndImageContext() }

        // White background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: finalSize))

        // Center the photo
        let photoRect = CGRect(
            x: (finalSize.width - targetSize.width) / 2,
            y: (finalSize.height - targetSize.height) / 2,
            width: targetSize.width,
            height: targetSize.height
        )

        drawPhotoToFillRect(firstPhoto, in: photoRect)

        // Add border
        addMinimalBorder(to: photoRect)

        // Add timestamp
        addTimestamp(to: finalSize)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func createStripLayout(photos: [UIImage]) -> UIImage? {
        let photoCount = min(photos.count, 3)
        guard photoCount > 0 else { return nil }

        let stripWidth: CGFloat = 400
        let photoHeight: CGFloat = 260
        let spacing: CGFloat = 20
        let borderWidth: CGFloat = 40
        let textSectionHeight: CGFloat = 80

        let totalHeight = (CGFloat(photoCount) * photoHeight) + (CGFloat(photoCount - 1) * spacing) + textSectionHeight + spacing + (2 * borderWidth)
        let finalSize = CGSize(width: stripWidth, height: totalHeight)

        UIGraphicsBeginImageContextWithOptions(finalSize, true, 0)
        defer { UIGraphicsEndImageContext() }

        // Clean white background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: finalSize))

        // Draw photos
        for (index, photo) in photos.prefix(photoCount).enumerated() {
            let y = borderWidth + (CGFloat(index) * (photoHeight + spacing))
            let photoRect = CGRect(
                x: borderWidth,
                y: y,
                width: stripWidth - (2 * borderWidth),
                height: photoHeight
            )

            drawPhotoToFillRect(photo, in: photoRect)

            // Add minimal border
            addMinimalBorder(to: photoRect)
        }

        // Add text section where 4th photo would be
        let textSectionY = borderWidth + (CGFloat(photoCount) * (photoHeight + spacing))
        let textSectionRect = CGRect(
            x: borderWidth,
            y: textSectionY,
            width: stripWidth - (2 * borderWidth),
            height: textSectionHeight
        )
        addSimpleTextSection(to: textSectionRect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func createGridLayout(photos: [UIImage]) -> UIImage? {
        let photoCount = min(photos.count, 4)
        guard photoCount > 0 else { return nil }

        let gridSize: CGFloat = 800
        let photoSize: CGFloat = (gridSize - 60) / 2 // 2x2 grid with spacing
        let spacing: CGFloat = 20
        let borderWidth: CGFloat = 20

        UIGraphicsBeginImageContextWithOptions(CGSize(width: gridSize, height: gridSize), true, 0)
        defer { UIGraphicsEndImageContext() }

        // White background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: CGSize(width: gridSize, height: gridSize)))

        // Define grid positions
        let positions = [
            CGPoint(x: borderWidth, y: borderWidth),
            CGPoint(x: borderWidth + photoSize + spacing, y: borderWidth),
            CGPoint(x: borderWidth, y: borderWidth + photoSize + spacing),
            CGPoint(x: borderWidth + photoSize + spacing, y: borderWidth + photoSize + spacing)
        ]

        // Draw photos
        for (index, photo) in photos.prefix(photoCount).enumerated() {
            let position = positions[index]
            let photoRect = CGRect(x: position.x, y: position.y, width: photoSize, height: photoSize)

            drawPhotoToFillRect(photo, in: photoRect)

            addMinimalBorder(to: photoRect)
        }

        // Add grid branding
        addGridBranding(to: CGSize(width: gridSize, height: gridSize))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func createCollageLayout(photos: [UIImage]) -> UIImage? {
        let photoCount = min(photos.count, 4)
        guard photoCount > 0 else { return nil }

        let canvasSize = CGSize(width: 800, height: 600)

        UIGraphicsBeginImageContextWithOptions(canvasSize, true, 0)
        defer { UIGraphicsEndImageContext() }

        // Gradient background
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil) else { return nil }
        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: canvasSize.width, y: canvasSize.height), options: [])

        // Define collage positions with rotation
        let configs = [
            (rect: CGRect(x: 50, y: 50, width: 200, height: 200), rotation: -15.0),
            (rect: CGRect(x: 300, y: 100, width: 180, height: 180), rotation: 10.0),
            (rect: CGRect(x: 100, y: 280, width: 220, height: 220), rotation: 5.0),
            (rect: CGRect(x: 400, y: 300, width: 160, height: 160), rotation: -8.0)
        ]

        // Draw photos with rotation
        for (index, photo) in photos.prefix(photoCount).enumerated() {
            let config = configs[index]

            context.saveGState()

            // Apply rotation
            let center = CGPoint(x: config.rect.midX, y: config.rect.midY)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: config.rotation * .pi / 180)
            context.translateBy(x: -center.x, y: -center.y)

            // Draw photo with shadow
            context.setShadow(offset: CGSize(width: 4, height: 4), blur: 8, color: UIColor.black.withAlphaComponent(0.3).cgColor)

            drawPhotoToFillRect(photo, in: config.rect)

            context.restoreGState()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - Helper Methods

    private func addMinimalBorder(to rect: CGRect) {
        UIColor.systemGray4.setStroke()
        let borderPath = UIBezierPath(rect: rect)
        borderPath.lineWidth = 1
        borderPath.stroke()
    }

    // MARK: - Simple Design Methods

    private func addSimpleWeddingHeader(to size: CGSize, headerHeight: CGFloat) {
        let coupleNames = "Shahnila & Josh"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .light),
            .foregroundColor: UIColor.black
        ]

        let textSize = coupleNames.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (headerHeight - textSize.height) / 2 + 20,
            width: textSize.width,
            height: textSize.height
        )

        coupleNames.draw(in: textRect, withAttributes: attributes)
    }

    private func addSimpleWeddingFooter(to size: CGSize, footerHeight: CGFloat) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateText = dateFormatter.string(from: Date())

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.systemGray
        ]

        let textSize = dateText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: size.height - footerHeight + (footerHeight - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        dateText.draw(in: textRect, withAttributes: attributes)
    }

    private func addSimpleWeddingTextSection(to rect: CGRect) {
        // Simple thank you message
        let message = "Thank you for celebrating with us"
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]

        let messageSize = message.size(withAttributes: messageAttributes)
        let messageRect = CGRect(
            x: rect.minX + (rect.width - messageSize.width) / 2,
            y: rect.minY + (rect.height - messageSize.height) / 2,
            width: messageSize.width,
            height: messageSize.height
        )
        message.draw(in: messageRect, withAttributes: messageAttributes)
    }

    private func addSimpleTextSection(to rect: CGRect) {
        // Simple thank you message
        let message = "Thanks for the memories"
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]

        let messageSize = message.size(withAttributes: messageAttributes)
        let messageRect = CGRect(
            x: rect.minX + (rect.width - messageSize.width) / 2,
            y: rect.minY + (rect.height - messageSize.height) / 2,
            width: messageSize.width,
            height: messageSize.height
        )
        message.draw(in: messageRect, withAttributes: messageAttributes)
    }

    private func addTimestamp(to size: CGSize) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let timestampText = dateFormatter.string(from: Date())

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]

        let textSize = timestampText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: size.width - textSize.width - 20,
            y: size.height - textSize.height - 20,
            width: textSize.width,
            height: textSize.height
        )

        timestampText.draw(in: textRect, withAttributes: attributes)
    }

    private func addStripBranding(to size: CGSize) {
        let brandText = "PHOTO BOOTH"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ]

        let textSize = brandText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: 10,
            width: textSize.width,
            height: textSize.height
        )

        brandText.draw(in: textRect, withAttributes: attributes)

        // Add date at bottom
        addTimestamp(to: size)
    }

    private func addGridBranding(to size: CGSize) {
        let brandText = "PHOTOBOOTH SESSION"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.darkGray
        ]

        let textSize = brandText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: size.height - 60,
            width: textSize.width,
            height: textSize.height
        )

        brandText.draw(in: textRect, withAttributes: attributes)
    }

    // MARK: - Photo Drawing Helpers

    private func drawPhotoToFillRect(_ photo: UIImage, in rect: CGRect) {
        // Calculate the scaling to fill the rect while maintaining aspect ratio
        let photoAspectRatio = photo.size.width / photo.size.height
        let rectAspectRatio = rect.width / rect.height

        var drawRect = rect

        if photoAspectRatio > rectAspectRatio {
            // Photo is wider - scale to fit height and center horizontally
            let scaledWidth = rect.height * photoAspectRatio
            drawRect = CGRect(
                x: rect.minX - (scaledWidth - rect.width) / 2,
                y: rect.minY,
                width: scaledWidth,
                height: rect.height
            )
        } else {
            // Photo is taller - scale to fit width and center vertically
            let scaledHeight = rect.width / photoAspectRatio
            drawRect = CGRect(
                x: rect.minX,
                y: rect.minY - (scaledHeight - rect.height) / 2,
                width: rect.width,
                height: scaledHeight
            )
        }

        // Clip to the original rect to prevent overflow
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.clip(to: rect)

        photo.draw(in: drawRect)

        context.restoreGState()
    }

    private func addSmileyFaceOverlay(to rect: CGRect) {
        // Position smiley face in bottom-right corner of the photo
        let smileySize: CGFloat = min(rect.width, rect.height) * 0.15 // 15% of the smaller dimension
        let smileyRect = CGRect(
            x: rect.maxX - smileySize - 10,
            y: rect.maxY - smileySize - 10,
            width: smileySize,
            height: smileySize
        )

        // Draw semi-transparent circle background
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()

        // Yellow background with transparency
        UIColor.systemYellow.withAlphaComponent(0.8).setFill()
        let backgroundCircle = UIBezierPath(ovalIn: smileyRect)
        backgroundCircle.fill()

        // Black border for the face
        UIColor.black.withAlphaComponent(0.6).setStroke()
        backgroundCircle.lineWidth = 1.5
        backgroundCircle.stroke()

        // Draw smiley face features
        let centerX = smileyRect.midX
        let centerY = smileyRect.midY
        let radius = smileySize / 2

        // Eyes
        let eyeRadius = radius * 0.15
        let eyeOffsetX = radius * 0.3
        let eyeOffsetY = radius * 0.25

        UIColor.black.withAlphaComponent(0.8).setFill()

        // Left eye
        let leftEye = UIBezierPath(ovalIn: CGRect(
            x: centerX - eyeOffsetX - eyeRadius,
            y: centerY - eyeOffsetY - eyeRadius,
            width: eyeRadius * 2,
            height: eyeRadius * 2
        ))
        leftEye.fill()

        // Right eye
        let rightEye = UIBezierPath(ovalIn: CGRect(
            x: centerX + eyeOffsetX - eyeRadius,
            y: centerY - eyeOffsetY - eyeRadius,
            width: eyeRadius * 2,
            height: eyeRadius * 2
        ))
        rightEye.fill()

        // Smile
        let smileRadius = radius * 0.5

        UIColor.black.withAlphaComponent(0.8).setStroke()
        let smilePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY + radius * 0.1),
                                   radius: smileRadius,
                                   startAngle: 0.3 * .pi,
                                   endAngle: 0.7 * .pi,
                                   clockwise: true)
        smilePath.lineWidth = 2
        smilePath.stroke()

        context.restoreGState()
    }

    // MARK: - Wedding Theme Helpers

    private func addWeddingBorder(to rect: CGRect) {
        let borderWidth: CGFloat = 8

        // Outer border with wedding colors
        UIColor.systemPink.withAlphaComponent(0.3).setStroke()
        let outerBorderPath = UIBezierPath(rect: rect.insetBy(dx: 2, dy: 2))
        outerBorderPath.lineWidth = 4
        outerBorderPath.stroke()

        // Inner decorative border
        UIColor.systemPink.withAlphaComponent(0.6).setStroke()
        let innerBorderPath = UIBezierPath(rect: rect.insetBy(dx: borderWidth, dy: borderWidth))
        innerBorderPath.lineWidth = 2
        innerBorderPath.stroke()
    }

    private func addWeddingHeader(to size: CGSize, headerHeight: CGFloat) {
        // Couple names
        let coupleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Georgia-BoldItalic", size: 32) ?? UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.8),
            .strokeColor: UIColor.white,
            .strokeWidth: -1.0
        ]

        let coupleSize = coupleNames.size(withAttributes: coupleAttributes)
        let coupleRect = CGRect(
            x: (size.width - coupleSize.width) / 2,
            y: 25,
            width: coupleSize.width,
            height: coupleSize.height
        )

        coupleNames.draw(in: coupleRect, withAttributes: coupleAttributes)

        // Add decorative hearts
        addWeddingDecorations(around: coupleRect, in: size)
    }

    private func addWeddingFooter(to size: CGSize, footerHeight: CGFloat) {
        let footerY = size.height - footerHeight + 10

        // Wedding date
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Georgia-Italic", size: 16) ?? UIFont.italicSystemFont(ofSize: 16),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.7)
        ]

        let dateSize = weddingDate.size(withAttributes: dateAttributes)
        let dateRect = CGRect(
            x: (size.width - dateSize.width) / 2,
            y: footerY,
            width: dateSize.width,
            height: dateSize.height
        )

        weddingDate.draw(in: dateRect, withAttributes: dateAttributes)

        // Hashtag
        let hashtagAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.6)
        ]

        let hashtagSize = eventHashtag.size(withAttributes: hashtagAttributes)
        let hashtagRect = CGRect(
            x: (size.width - hashtagSize.width) / 2,
            y: footerY + 25,
            width: hashtagSize.width,
            height: hashtagSize.height
        )

        eventHashtag.draw(in: hashtagRect, withAttributes: hashtagAttributes)

        // Thank you message
        let thankYouText = "Thank you for celebrating with us! ♥"
        let thankYouAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.5)
        ]

        let thankYouSize = thankYouText.size(withAttributes: thankYouAttributes)
        let thankYouRect = CGRect(
            x: (size.width - thankYouSize.width) / 2,
            y: footerY + 50,
            width: thankYouSize.width,
            height: thankYouSize.height
        )

        thankYouText.draw(in: thankYouRect, withAttributes: thankYouAttributes)
    }

    private func addWeddingPhotoFrame(to rect: CGRect) {
        // Elegant photo frame
        UIColor.systemPink.withAlphaComponent(0.4).setStroke()
        let framePath = UIBezierPath(rect: rect)
        framePath.lineWidth = 3
        framePath.stroke()

        // Inner frame
        UIColor.white.setStroke()
        let innerFramePath = UIBezierPath(rect: rect.insetBy(dx: 2, dy: 2))
        innerFramePath.lineWidth = 1
        innerFramePath.stroke()
    }

    private func addWeddingDecorations(around rect: CGRect, in size: CGSize) {
        // Add heart symbols around the couple names
        let heartSymbol = "♥"
        let heartAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.6)
        ]

        // Left heart
        let leftHeartRect = CGRect(
            x: rect.minX - 35,
            y: rect.midY - 10,
            width: 20,
            height: 20
        )
        heartSymbol.draw(in: leftHeartRect, withAttributes: heartAttributes)

        // Right heart
        let rightHeartRect = CGRect(
            x: rect.maxX + 15,
            y: rect.midY - 10,
            width: 20,
            height: 20
        )
        heartSymbol.draw(in: rightHeartRect, withAttributes: heartAttributes)
    }

    private func addWeddingTextSection(to rect: CGRect) {
        // Add elegant background for text section
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPink.withAlphaComponent(0.1).cgColor, UIColor.white.cgColor]
        gradient.frame = rect

        // Background with subtle pink tint
        UIColor.systemPink.withAlphaComponent(0.05).setFill()
        UIRectFill(rect)

        // Add decorative border
        UIColor.systemPink.withAlphaComponent(0.4).setStroke()
        let borderPath = UIBezierPath(rect: rect)
        borderPath.lineWidth = 2
        borderPath.stroke()

        // Main message
        let mainMessage = "Thanks for celebrating with us!"
        let mainAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Georgia-BoldItalic", size: 24) ?? UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.8)
        ]

        let mainSize = mainMessage.size(withAttributes: mainAttributes)
        let mainRect = CGRect(
            x: rect.minX + (rect.width - mainSize.width) / 2,
            y: rect.minY + 15,
            width: mainSize.width,
            height: mainSize.height
        )
        mainMessage.draw(in: mainRect, withAttributes: mainAttributes)

        // Hearts decoration
        let heartsText = "♥ ♥ ♥"
        let heartsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.6)
        ]

        let heartsSize = heartsText.size(withAttributes: heartsAttributes)
        let heartsRect = CGRect(
            x: rect.minX + (rect.width - heartsSize.width) / 2,
            y: rect.minY + 50,
            width: heartsSize.width,
            height: heartsSize.height
        )
        heartsText.draw(in: heartsRect, withAttributes: heartsAttributes)

        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateText = dateFormatter.string(from: Date())

        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Georgia-Italic", size: 14) ?? UIFont.italicSystemFont(ofSize: 14),
            .foregroundColor: UIColor.systemPink.withAlphaComponent(0.7)
        ]

        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(
            x: rect.minX + (rect.width - dateSize.width) / 2,
            y: rect.minY + 80,
            width: dateSize.width,
            height: dateSize.height
        )
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
    }

    private func addRegularTextSection(to rect: CGRect) {
        // Add subtle background
        UIColor.systemGray6.setFill()
        UIRectFill(rect)

        // Add border
        UIColor.systemGray4.setStroke()
        let borderPath = UIBezierPath(rect: rect)
        borderPath.lineWidth = 2
        borderPath.stroke()

        // Main message
        let mainMessage = "Thanks for the memories!"
        let mainAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.darkGray
        ]

        let mainSize = mainMessage.size(withAttributes: mainAttributes)
        let mainRect = CGRect(
            x: rect.minX + (rect.width - mainSize.width) / 2,
            y: rect.minY + 15,
            width: mainSize.width,
            height: mainSize.height
        )
        mainMessage.draw(in: mainRect, withAttributes: mainAttributes)

        // Smiley face
        let smileyText = "😊"
        let smileyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24)
        ]

        let smileySize = smileyText.size(withAttributes: smileyAttributes)
        let smileyRect = CGRect(
            x: rect.minX + (rect.width - smileySize.width) / 2,
            y: rect.minY + 45,
            width: smileySize.width,
            height: smileySize.height
        )
        smileyText.draw(in: smileyRect, withAttributes: smileyAttributes)

        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateText = dateFormatter.string(from: Date())

        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]

        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(
            x: rect.minX + (rect.width - dateSize.width) / 2,
            y: rect.minY + 75,
            width: dateSize.width,
            height: dateSize.height
        )
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
    }
}

// MARK: - UIImage Extensions

extension UIImage {
    func resizedToFit(size: CGSize) -> UIImage {
        let aspectRatio = self.size.width / self.size.height
        let targetAspectRatio = size.width / size.height

        var targetSize = size

        if aspectRatio > targetAspectRatio {
            // Image is wider, fit to width
            targetSize.height = size.width / aspectRatio
        } else {
            // Image is taller, fit to height
            targetSize.width = size.height * aspectRatio
        }

        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}