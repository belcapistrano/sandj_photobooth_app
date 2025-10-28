import Foundation

enum FilterType: String, CaseIterable, Codable {
    case none = "None"
    case vintage = "Vintage"
    case blackAndWhite = "B&W"
    case sepia = "Sepia"
    case vibrant = "Vibrant"
    case dramatic = "Dramatic"
    case cool = "Cool"
    case warm = "Warm"

    var displayName: String {
        return rawValue
    }

    var description: String {
        switch self {
        case .none:
            return "Original photo"
        case .vintage:
            return "Classic vintage look"
        case .blackAndWhite:
            return "Timeless black and white"
        case .sepia:
            return "Warm sepia tone"
        case .vibrant:
            return "Enhanced colors"
        case .dramatic:
            return "High contrast drama"
        case .cool:
            return "Cool blue tones"
        case .warm:
            return "Warm golden tones"
        }
    }
}