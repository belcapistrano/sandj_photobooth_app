import Foundation

enum StorageError: Error, LocalizedError {
    case compressionFailed
    case fileNotFound
    case writeFailed
    case readFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image data"
        case .fileNotFound:
            return "File not found"
        case .writeFailed:
            return "Failed to write data to file"
        case .readFailed:
            return "Failed to read data from file"
        case .invalidData:
            return "Invalid data format"
        }
    }
}