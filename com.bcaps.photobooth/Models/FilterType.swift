import Foundation

enum FilterType: String, CaseIterable, Codable {
    case original = "Original"
    case warmRomance = "Warm"
    case classicFilm = "Classic"
    case elegantBW = "B&W"
    case softDream = "Soft"

    var displayName: String {
        return rawValue
    }

    var description: String {
        switch self {
        case .original:
            return "Natural, unfiltered photos"
        case .warmRomance:
            return "Warm, golden tones for romantic feel"
        case .classicFilm:
            return "Vintage film look with soft contrast"
        case .elegantBW:
            return "Classic black and white with enhanced contrast"
        case .softDream:
            return "Soft, dreamy effect with subtle glow"
        }
    }

    var icon: String {
        switch self {
        case .original:
            return "camera"
        case .warmRomance:
            return "sun.max"
        case .classicFilm:
            return "film"
        case .elegantBW:
            return "circle.lefthalf.filled"
        case .softDream:
            return "sparkles"
        }
    }
}