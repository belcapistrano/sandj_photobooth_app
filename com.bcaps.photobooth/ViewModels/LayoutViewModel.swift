import Foundation
import UIKit

class LayoutViewModel: ObservableObject {

    @Published var availableLayouts: [LayoutTemplate] = []
    @Published var selectedLayout: LayoutTemplate?

    init() {
        loadLayouts()
        loadSelectedLayout()
    }

    private func loadLayouts() {
        availableLayouts = LayoutTemplate.defaultLayouts
    }

    private func loadSelectedLayout() {
        let settings = SettingsStorage.shared
        if let layoutName: String = settings.get(for: .defaultFilter) {
            selectedLayout = availableLayouts.first { $0.name == layoutName }
        }

        if selectedLayout == nil {
            selectedLayout = availableLayouts.first
        }
    }

    func selectLayout(_ layout: LayoutTemplate) {
        selectedLayout = layout
        saveSelectedLayout()
    }

    private func saveSelectedLayout() {
        guard let layout = selectedLayout else { return }
        let settings = SettingsStorage.shared
        settings.set(layout.name, for: .defaultFilter)
    }

    func generatePreviewImage(for layout: LayoutTemplate, with size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            UIColor.systemGray4.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            switch layout.photoCount {
            case 1:
                drawSinglePhotoLayout(in: CGRect(origin: .zero, size: size), context: context)
            case 4 where layout.name.contains("Strip"):
                drawPhotoStripLayout(in: CGRect(origin: .zero, size: size), context: context)
            case 4:
                drawGrid2x2Layout(in: CGRect(origin: .zero, size: size), context: context)
            case 6:
                drawCollageLayout(in: CGRect(origin: .zero, size: size), context: context)
            default:
                drawSinglePhotoLayout(in: CGRect(origin: .zero, size: size), context: context)
            }
        }
    }

    private func drawSinglePhotoLayout(in rect: CGRect, context: UIGraphicsImageRendererContext) {
        let photoRect = rect.insetBy(dx: 8, dy: 8)
        UIColor.systemGray3.setFill()
        context.fill(photoRect)
    }

    private func drawPhotoStripLayout(in rect: CGRect, context: UIGraphicsImageRendererContext) {
        let photoHeight = (rect.height - 40) / 4
        let photoWidth = rect.width - 16

        for i in 0..<4 {
            let y = 8 + CGFloat(i) * (photoHeight + 8)
            let photoRect = CGRect(x: 8, y: y, width: photoWidth, height: photoHeight)
            UIColor.systemGray3.setFill()
            context.fill(photoRect)
        }
    }

    private func drawGrid2x2Layout(in rect: CGRect, context: UIGraphicsImageRendererContext) {
        let photoWidth = (rect.width - 24) / 2
        let photoHeight = (rect.height - 24) / 2

        for row in 0..<2 {
            for col in 0..<2 {
                let x = 8 + CGFloat(col) * (photoWidth + 8)
                let y = 8 + CGFloat(row) * (photoHeight + 8)
                let photoRect = CGRect(x: x, y: y, width: photoWidth, height: photoHeight)
                UIColor.systemGray3.setFill()
                context.fill(photoRect)
            }
        }
    }

    private func drawCollageLayout(in rect: CGRect, context: UIGraphicsImageRendererContext) {
        let photoWidth = (rect.width - 24) / 2
        let photoHeight = (rect.height - 32) / 3

        for row in 0..<3 {
            for col in 0..<2 {
                let x = 8 + CGFloat(col) * (photoWidth + 8)
                let y = 8 + CGFloat(row) * (photoHeight + 8)
                let photoRect = CGRect(x: x, y: y, width: photoWidth, height: photoHeight)
                UIColor.systemGray3.setFill()
                context.fill(photoRect)
            }
        }
    }

    var hasSelectedLayout: Bool {
        return selectedLayout != nil
    }

    var selectedLayoutName: String {
        return selectedLayout?.name ?? "No Layout Selected"
    }

    var selectedLayoutDescription: String {
        return selectedLayout?.description ?? ""
    }

    var selectedPhotoCount: Int {
        return selectedLayout?.photoCount ?? 0
    }
}