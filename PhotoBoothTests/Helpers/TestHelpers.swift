import XCTest
import UIKit
import Foundation
@testable import com_bcaps_photobooth

class TestHelpers {

    // MARK: - Test Image Creation

    static func createTestImage(color: UIColor = .red, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    static func createTestImageData(color: UIColor = .red, size: CGSize = CGSize(width: 100, height: 100)) -> Data {
        let image = createTestImage(color: color, size: size)
        return image.jpegData(compressionQuality: 0.8) ?? Data()
    }

    // MARK: - Test Models

    static func createTestPhoto() -> Photo {
        return Photo()
    }

    static func createTestPhotos(count: Int) -> [Photo] {
        return (0..<count).map { _ in createTestPhoto() }
    }

    static func createTestPhotoSession(photoCount: Int = 3) -> PhotoSession {
        let photos = createTestPhotos(count: photoCount)
        return PhotoSession(photos: photos)
    }

    static func createTestLayoutTemplate() -> LayoutTemplate {
        return LayoutTemplate(
            name: "Test Layout",
            description: "Test layout description",
            photoCount: 4,
            aspectRatio: CGSize(width: 2, height: 3)
        )
    }

    // MARK: - File System Helpers

    static func getTestDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("Tests")
    }

    static func createTestDirectory() throws {
        let testDir = getTestDocumentsDirectory()
        if !FileManager.default.fileExists(atPath: testDir.path) {
            try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        }
    }

    static func cleanupTestFiles() {
        let testDir = getTestDocumentsDirectory()
        try? FileManager.default.removeItem(at: testDir)
    }

    static func deleteTestFiles(matching pattern: String) {
        let testDir = getTestDocumentsDirectory()
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: testDir.path) else { return }

        for file in files {
            if file.contains(pattern) {
                let filePath = testDir.appendingPathComponent(file)
                try? FileManager.default.removeItem(at: filePath)
            }
        }
    }

    // MARK: - Async Test Helpers

    static func waitForAsyncOperation(timeout: TimeInterval = 1.0, operation: @escaping (@escaping () -> Void) -> Void) {
        let expectation = XCTestExpectation(description: "Async operation")

        operation {
            expectation.fulfill()
        }

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Async operation timed out")
    }

    // MARK: - Mock Helpers

    static func createMockError(message: String = "Test error") -> NSError {
        return NSError(domain: "TestDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
    }

    // MARK: - UserDefaults Testing

    static func createTestUserDefaults() -> UserDefaults {
        let suiteName = "test-\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        return userDefaults
    }

    static func cleanupTestUserDefaults(_ userDefaults: UserDefaults) {
        if let suiteName = userDefaults.persistentDomain(forName: userDefaults.description) {
            userDefaults.removePersistentDomain(forName: userDefaults.description)
        }
    }

    // MARK: - Performance Testing

    static func measureTime<T>(operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }

    // MARK: - Memory Testing

    static func measureMemoryUsage<T>(operation: () throws -> T) rethrows -> (result: T, memoryUsed: Int64) {
        let startMemory = mach_task_basic_info()
        let result = try operation()
        let endMemory = mach_task_basic_info()
        let memoryUsed = Int64(endMemory.resident_size) - Int64(startMemory.resident_size)
        return (result, memoryUsed)
    }

    private static func mach_task_basic_info() -> mach_task_basic_info {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return mach_task_basic_info()
        }

        return info
    }

    // MARK: - JSON Testing Helpers

    static func encodeToJSON<T: Codable>(_ object: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(object)
    }

    static func decodeFromJSON<T: Codable>(_ data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }

    static func assertJSONEquality<T: Codable & Equatable>(_ original: T, type: T.Type, file: StaticString = #file, line: UInt = #line) {
        do {
            let data = try encodeToJSON(original)
            let decoded = try decodeFromJSON(data, type: type)
            XCTAssertEqual(original, decoded, "JSON encode/decode failed", file: file, line: line)
        } catch {
            XCTFail("JSON serialization failed: \(error)", file: file, line: line)
        }
    }
}