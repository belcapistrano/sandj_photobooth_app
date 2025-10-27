import XCTest
import Foundation
@testable import com_bcaps_photobooth

class PhotoTests: XCTestCase {

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testPhotoInitialization() {
        // Test default initialization
        let photo = Photo()

        XCTAssertNotNil(photo.id)
        XCTAssertNotNil(photo.timestamp)
        XCTAssertNotNil(photo.filename)
        XCTAssertEqual(photo.filename, "\(photo.id.uuidString).jpg")
    }

    func testPhotoInitializationWithCustomValues() {
        // Test initialization with custom values
        let customId = UUID()
        let customTimestamp = Date(timeIntervalSince1970: 1000000)

        let photo = Photo(id: customId, timestamp: customTimestamp)

        XCTAssertEqual(photo.id, customId)
        XCTAssertEqual(photo.timestamp, customTimestamp)
        XCTAssertEqual(photo.filename, "\(customId.uuidString).jpg")
    }

    func testPhotoFilenameGeneration() {
        // Test that filename is generated correctly
        let photo = Photo()
        let expectedFilename = "\(photo.id.uuidString).jpg"

        XCTAssertEqual(photo.filename, expectedFilename)
        XCTAssertTrue(photo.filename.hasSuffix(".jpg"))
        XCTAssertTrue(photo.filename.contains(photo.id.uuidString))
    }

    // MARK: - Codable Tests

    func testPhotoCodableConformance() {
        // Test that Photo can be encoded and decoded
        let originalPhoto = Photo()

        TestHelpers.assertJSONEquality(originalPhoto, type: Photo.self)
    }

    func testPhotoCodableWithCustomValues() {
        // Test encoding/decoding with custom values
        let customId = UUID()
        let customTimestamp = Date()
        let photo = Photo(id: customId, timestamp: customTimestamp)

        TestHelpers.assertJSONEquality(photo, type: Photo.self)
    }

    func testPhotoCodablePreservesAllProperties() {
        // Test that all properties are preserved during encoding/decoding
        let originalPhoto = Photo()

        do {
            let data = try TestHelpers.encodeToJSON(originalPhoto)
            let decodedPhoto = try TestHelpers.decodeFromJSON(data, type: Photo.self)

            XCTAssertEqual(originalPhoto.id, decodedPhoto.id)
            XCTAssertEqual(originalPhoto.timestamp.timeIntervalSince1970,
                          decodedPhoto.timestamp.timeIntervalSince1970,
                          accuracy: 0.001)
            XCTAssertEqual(originalPhoto.filename, decodedPhoto.filename)
        } catch {
            XCTFail("Codable test failed: \(error)")
        }
    }

    // MARK: - Equatable Tests

    func testPhotoEquality() {
        // Test that photos with same properties are equal
        let id = UUID()
        let timestamp = Date()

        let photo1 = Photo(id: id, timestamp: timestamp)
        let photo2 = Photo(id: id, timestamp: timestamp)

        XCTAssertEqual(photo1, photo2)
    }

    func testPhotoInequality() {
        // Test that photos with different properties are not equal
        let photo1 = Photo()
        let photo2 = Photo()

        XCTAssertNotEqual(photo1, photo2) // Different IDs
    }

    func testPhotoInequalityDifferentTimestamp() {
        // Test inequality with different timestamps
        let id = UUID()
        let photo1 = Photo(id: id, timestamp: Date())
        let photo2 = Photo(id: id, timestamp: Date().addingTimeInterval(100))

        XCTAssertNotEqual(photo1, photo2)
    }

    // MARK: - Property Tests

    func testPhotoIdUniqueness() {
        // Test that each photo gets a unique ID
        let photos = (0..<10).map { _ in Photo() }
        let ids = Set(photos.map { $0.id })

        XCTAssertEqual(ids.count, 10, "All photo IDs should be unique")
    }

    func testPhotoTimestampAccuracy() {
        // Test that timestamp is set correctly
        let beforeCreation = Date()
        let photo = Photo()
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(photo.timestamp, beforeCreation)
        XCTAssertLessThanOrEqual(photo.timestamp, afterCreation)
    }

    func testPhotoFilenameFormat() {
        // Test filename format consistency
        let photo = Photo()

        XCTAssertTrue(photo.filename.hasSuffix(".jpg"))
        XCTAssertTrue(photo.filename.count > 4) // More than just ".jpg"
        XCTAssertFalse(photo.filename.contains(" ")) // No spaces
        XCTAssertFalse(photo.filename.contains("/")) // No path separators
    }

    // MARK: - Performance Tests

    func testPhotoInitializationPerformance() {
        // Test that photo initialization is fast
        measure {
            for _ in 0..<1000 {
                _ = Photo()
            }
        }
    }

    func testPhotoCodablePerformance() {
        // Test that encoding/decoding is fast
        let photos = (0..<100).map { _ in Photo() }

        measure {
            for photo in photos {
                do {
                    let data = try TestHelpers.encodeToJSON(photo)
                    _ = try TestHelpers.decodeFromJSON(data, type: Photo.self)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    // MARK: - Edge Cases

    func testPhotoWithVeryOldTimestamp() {
        // Test with very old timestamp
        let oldTimestamp = Date(timeIntervalSince1970: 0)
        let photo = Photo(id: UUID(), timestamp: oldTimestamp)

        XCTAssertEqual(photo.timestamp, oldTimestamp)
        TestHelpers.assertJSONEquality(photo, type: Photo.self)
    }

    func testPhotoWithFutureTimestamp() {
        // Test with future timestamp
        let futureTimestamp = Date(timeIntervalSinceNow: 86400 * 365) // 1 year from now
        let photo = Photo(id: UUID(), timestamp: futureTimestamp)

        XCTAssertEqual(photo.timestamp, futureTimestamp)
        TestHelpers.assertJSONEquality(photo, type: Photo.self)
    }

    func testPhotoWithMaxUUID() {
        // Test with specific UUID patterns
        let maxUUID = UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!
        let photo = Photo(id: maxUUID, timestamp: Date())

        XCTAssertEqual(photo.id, maxUUID)
        XCTAssertTrue(photo.filename.contains("FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"))
    }

    func testPhotoWithZeroUUID() {
        // Test with zero UUID
        let zeroUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let photo = Photo(id: zeroUUID, timestamp: Date())

        XCTAssertEqual(photo.id, zeroUUID)
        XCTAssertTrue(photo.filename.contains("00000000-0000-0000-0000-000000000000"))
    }

    // MARK: - Array Operations Tests

    func testPhotoArraySorting() {
        // Test sorting photos by timestamp
        let timestamps = [
            Date(timeIntervalSince1970: 1000),
            Date(timeIntervalSince1970: 500),
            Date(timeIntervalSince1970: 1500)
        ]

        let photos = timestamps.map { Photo(id: UUID(), timestamp: $0) }
        let sortedPhotos = photos.sorted { $0.timestamp < $1.timestamp }

        XCTAssertEqual(sortedPhotos[0].timestamp.timeIntervalSince1970, 500)
        XCTAssertEqual(sortedPhotos[1].timestamp.timeIntervalSince1970, 1000)
        XCTAssertEqual(sortedPhotos[2].timestamp.timeIntervalSince1970, 1500)
    }

    func testPhotoArrayFiltering() {
        // Test filtering photos
        let now = Date()
        let past = now.addingTimeInterval(-3600)
        let future = now.addingTimeInterval(3600)

        let photos = [
            Photo(id: UUID(), timestamp: past),
            Photo(id: UUID(), timestamp: now),
            Photo(id: UUID(), timestamp: future)
        ]

        let recentPhotos = photos.filter { $0.timestamp >= now }
        XCTAssertEqual(recentPhotos.count, 2)
    }

    // MARK: - Memory Tests

    func testPhotoMemoryUsage() {
        // Test that photos don't use excessive memory
        let (photos, memoryUsed) = TestHelpers.measureMemoryUsage {
            return (0..<1000).map { _ in Photo() }
        }

        XCTAssertEqual(photos.count, 1000)
        // Each photo should use minimal memory (rough estimate)
        XCTAssertLessThan(memoryUsed, 1024 * 1024) // Less than 1MB for 1000 photos
    }
}