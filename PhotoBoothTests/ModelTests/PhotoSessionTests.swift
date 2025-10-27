import XCTest
import Foundation
@testable import com_bcaps_photobooth

class PhotoSessionTests: XCTestCase {

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testPhotoSessionDefaultInitialization() {
        // Test default initialization
        let session = PhotoSession()

        XCTAssertNotNil(session.id)
        XCTAssertTrue(session.photos.isEmpty)
        XCTAssertNotNil(session.timestamp)
        XCTAssertFalse(session.isComplete)
    }

    func testPhotoSessionInitializationWithPhotos() {
        // Test initialization with photos
        let photos = TestHelpers.createTestPhotos(count: 3)
        let session = PhotoSession(photos: photos)

        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.photos.count, 3)
        XCTAssertEqual(session.photos, photos)
        XCTAssertFalse(session.isComplete)
    }

    func testPhotoSessionInitializationWithAllProperties() {
        // Test initialization with all properties
        let id = UUID()
        let photos = TestHelpers.createTestPhotos(count: 2)
        let timestamp = Date()
        let isComplete = true

        let session = PhotoSession(id: id, photos: photos, timestamp: timestamp, isComplete: isComplete)

        XCTAssertEqual(session.id, id)
        XCTAssertEqual(session.photos, photos)
        XCTAssertEqual(session.timestamp, timestamp)
        XCTAssertEqual(session.isComplete, isComplete)
    }

    // MARK: - Codable Tests

    func testPhotoSessionCodableConformance() {
        // Test that PhotoSession can be encoded and decoded
        let photos = TestHelpers.createTestPhotos(count: 2)
        let session = PhotoSession(photos: photos, isComplete: true)

        TestHelpers.assertJSONEquality(session, type: PhotoSession.self)
    }

    func testPhotoSessionCodableWithEmptyPhotos() {
        // Test encoding/decoding with empty photos array
        let session = PhotoSession()

        TestHelpers.assertJSONEquality(session, type: PhotoSession.self)
    }

    func testPhotoSessionCodablePreservesAllProperties() {
        // Test that all properties are preserved during encoding/decoding
        let photos = TestHelpers.createTestPhotos(count: 3)
        let originalSession = PhotoSession(photos: photos, isComplete: true)

        do {
            let data = try TestHelpers.encodeToJSON(originalSession)
            let decodedSession = try TestHelpers.decodeFromJSON(data, type: PhotoSession.self)

            XCTAssertEqual(originalSession.id, decodedSession.id)
            XCTAssertEqual(originalSession.photos, decodedSession.photos)
            XCTAssertEqual(originalSession.timestamp.timeIntervalSince1970,
                          decodedSession.timestamp.timeIntervalSince1970,
                          accuracy: 0.001)
            XCTAssertEqual(originalSession.isComplete, decodedSession.isComplete)
        } catch {
            XCTFail("Codable test failed: \(error)")
        }
    }

    // MARK: - Equatable Tests

    func testPhotoSessionEquality() {
        // Test that sessions with same properties are equal
        let id = UUID()
        let photos = TestHelpers.createTestPhotos(count: 2)
        let timestamp = Date()

        let session1 = PhotoSession(id: id, photos: photos, timestamp: timestamp, isComplete: false)
        let session2 = PhotoSession(id: id, photos: photos, timestamp: timestamp, isComplete: false)

        XCTAssertEqual(session1, session2)
    }

    func testPhotoSessionInequality() {
        // Test that sessions with different properties are not equal
        let session1 = PhotoSession()
        let session2 = PhotoSession()

        XCTAssertNotEqual(session1, session2) // Different IDs
    }

    func testPhotoSessionInequalityDifferentPhotos() {
        // Test inequality with different photos
        let id = UUID()
        let timestamp = Date()
        let photos1 = TestHelpers.createTestPhotos(count: 2)
        let photos2 = TestHelpers.createTestPhotos(count: 3)

        let session1 = PhotoSession(id: id, photos: photos1, timestamp: timestamp, isComplete: false)
        let session2 = PhotoSession(id: id, photos: photos2, timestamp: timestamp, isComplete: false)

        XCTAssertNotEqual(session1, session2)
    }

    func testPhotoSessionInequalityDifferentCompletionStatus() {
        // Test inequality with different completion status
        let id = UUID()
        let photos = TestHelpers.createTestPhotos(count: 2)
        let timestamp = Date()

        let session1 = PhotoSession(id: id, photos: photos, timestamp: timestamp, isComplete: false)
        let session2 = PhotoSession(id: id, photos: photos, timestamp: timestamp, isComplete: true)

        XCTAssertNotEqual(session1, session2)
    }

    // MARK: - Property Tests

    func testPhotoSessionIdUniqueness() {
        // Test that each session gets a unique ID
        let sessions = (0..<10).map { _ in PhotoSession() }
        let ids = Set(sessions.map { $0.id })

        XCTAssertEqual(ids.count, 10, "All session IDs should be unique")
    }

    func testPhotoSessionTimestampAccuracy() {
        // Test that timestamp is set correctly
        let beforeCreation = Date()
        let session = PhotoSession()
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(session.timestamp, beforeCreation)
        XCTAssertLessThanOrEqual(session.timestamp, afterCreation)
    }

    func testPhotoSessionDefaultState() {
        // Test default state of new session
        let session = PhotoSession()

        XCTAssertTrue(session.photos.isEmpty)
        XCTAssertFalse(session.isComplete)
        XCTAssertNotNil(session.id)
        XCTAssertNotNil(session.timestamp)
    }

    // MARK: - Photos Management Tests

    func testPhotoSessionWithSinglePhoto() {
        // Test session with one photo
        let photo = TestHelpers.createTestPhoto()
        let session = PhotoSession(photos: [photo])

        XCTAssertEqual(session.photos.count, 1)
        XCTAssertEqual(session.photos.first, photo)
    }

    func testPhotoSessionWithMultiplePhotos() {
        // Test session with multiple photos
        let photos = TestHelpers.createTestPhotos(count: 5)
        let session = PhotoSession(photos: photos)

        XCTAssertEqual(session.photos.count, 5)
        XCTAssertEqual(session.photos, photos)
    }

    func testPhotoSessionPhotosOrder() {
        // Test that photos maintain their order
        let photos = TestHelpers.createTestPhotos(count: 3)
        let session = PhotoSession(photos: photos)

        for (index, photo) in photos.enumerated() {
            XCTAssertEqual(session.photos[index], photo)
        }
    }

    // MARK: - Completion State Tests

    func testPhotoSessionCompletionState() {
        // Test completion state changes
        let session1 = PhotoSession(isComplete: false)
        let session2 = PhotoSession(isComplete: true)

        XCTAssertFalse(session1.isComplete)
        XCTAssertTrue(session2.isComplete)
    }

    func testPhotoSessionModifyingCompletion() {
        // Test creating sessions with different completion states
        let photos = TestHelpers.createTestPhotos(count: 2)

        let incompleteSession = PhotoSession(photos: photos, isComplete: false)
        let completeSession = PhotoSession(photos: photos, isComplete: true)

        XCTAssertFalse(incompleteSession.isComplete)
        XCTAssertTrue(completeSession.isComplete)
    }

    // MARK: - Edge Cases

    func testPhotoSessionWithEmptyPhotosArray() {
        // Test session with explicitly empty photos array
        let session = PhotoSession(photos: [])

        XCTAssertTrue(session.photos.isEmpty)
        XCTAssertEqual(session.photos.count, 0)
    }

    func testPhotoSessionWithVeryOldTimestamp() {
        // Test with very old timestamp
        let oldTimestamp = Date(timeIntervalSince1970: 0)
        let session = PhotoSession(timestamp: oldTimestamp)

        XCTAssertEqual(session.timestamp, oldTimestamp)
        TestHelpers.assertJSONEquality(session, type: PhotoSession.self)
    }

    func testPhotoSessionWithFutureTimestamp() {
        // Test with future timestamp
        let futureTimestamp = Date(timeIntervalSinceNow: 86400 * 365) // 1 year from now
        let session = PhotoSession(timestamp: futureTimestamp)

        XCTAssertEqual(session.timestamp, futureTimestamp)
        TestHelpers.assertJSONEquality(session, type: PhotoSession.self)
    }

    func testPhotoSessionWithMaxPhotos() {
        // Test session with many photos
        let manyPhotos = TestHelpers.createTestPhotos(count: 100)
        let session = PhotoSession(photos: manyPhotos)

        XCTAssertEqual(session.photos.count, 100)
        TestHelpers.assertJSONEquality(session, type: PhotoSession.self)
    }

    // MARK: - Performance Tests

    func testPhotoSessionInitializationPerformance() {
        // Test that session initialization is fast
        let photos = TestHelpers.createTestPhotos(count: 10)

        measure {
            for _ in 0..<1000 {
                _ = PhotoSession(photos: photos)
            }
        }
    }

    func testPhotoSessionCodablePerformance() {
        // Test that encoding/decoding is fast
        let photos = TestHelpers.createTestPhotos(count: 10)
        let sessions = (0..<50).map { _ in PhotoSession(photos: photos) }

        measure {
            for session in sessions {
                do {
                    let data = try TestHelpers.encodeToJSON(session)
                    _ = try TestHelpers.decodeFromJSON(data, type: PhotoSession.self)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    // MARK: - Array Operations Tests

    func testPhotoSessionArraySorting() {
        // Test sorting sessions by timestamp
        let timestamps = [
            Date(timeIntervalSince1970: 1000),
            Date(timeIntervalSince1970: 500),
            Date(timeIntervalSince1970: 1500)
        ]

        let sessions = timestamps.map { PhotoSession(timestamp: $0) }
        let sortedSessions = sessions.sorted { $0.timestamp < $1.timestamp }

        XCTAssertEqual(sortedSessions[0].timestamp.timeIntervalSince1970, 500)
        XCTAssertEqual(sortedSessions[1].timestamp.timeIntervalSince1970, 1000)
        XCTAssertEqual(sortedSessions[2].timestamp.timeIntervalSince1970, 1500)
    }

    func testPhotoSessionArrayFiltering() {
        // Test filtering sessions by completion status
        let sessions = [
            PhotoSession(isComplete: true),
            PhotoSession(isComplete: false),
            PhotoSession(isComplete: true),
            PhotoSession(isComplete: false)
        ]

        let completeSessions = sessions.filter { $0.isComplete }
        let incompleteSessions = sessions.filter { !$0.isComplete }

        XCTAssertEqual(completeSessions.count, 2)
        XCTAssertEqual(incompleteSessions.count, 2)
    }

    func testPhotoSessionFilterByPhotoCount() {
        // Test filtering sessions by photo count
        let sessions = [
            PhotoSession(photos: TestHelpers.createTestPhotos(count: 1)),
            PhotoSession(photos: TestHelpers.createTestPhotos(count: 3)),
            PhotoSession(photos: TestHelpers.createTestPhotos(count: 5)),
            PhotoSession(photos: [])
        ]

        let sessionsWithPhotos = sessions.filter { !$0.photos.isEmpty }
        let sessionsWithMultiplePhotos = sessions.filter { $0.photos.count > 2 }

        XCTAssertEqual(sessionsWithPhotos.count, 3)
        XCTAssertEqual(sessionsWithMultiplePhotos.count, 2)
    }

    // MARK: - Memory Tests

    func testPhotoSessionMemoryUsage() {
        // Test that sessions don't use excessive memory
        let photos = TestHelpers.createTestPhotos(count: 5)

        let (sessions, memoryUsed) = TestHelpers.measureMemoryUsage {
            return (0..<100).map { _ in PhotoSession(photos: photos) }
        }

        XCTAssertEqual(sessions.count, 100)
        // Memory usage should be reasonable
        XCTAssertLessThan(memoryUsed, 10 * 1024 * 1024) // Less than 10MB for 100 sessions with 5 photos each
    }

    // MARK: - Integration with Photo Model

    func testPhotoSessionWithRealPhotos() {
        // Test session with actual Photo instances
        let photo1 = Photo()
        let photo2 = Photo()
        let photo3 = Photo()

        let session = PhotoSession(photos: [photo1, photo2, photo3])

        XCTAssertEqual(session.photos.count, 3)
        XCTAssertEqual(session.photos[0], photo1)
        XCTAssertEqual(session.photos[1], photo2)
        XCTAssertEqual(session.photos[2], photo3)
    }

    func testPhotoSessionModificationCreatesNewInstance() {
        // Test that modifying properties creates new instances (struct behavior)
        let originalSession = PhotoSession()
        let photo = TestHelpers.createTestPhoto()

        let modifiedSession = PhotoSession(
            id: originalSession.id,
            photos: [photo],
            timestamp: originalSession.timestamp,
            isComplete: true
        )

        XCTAssertEqual(originalSession.photos.count, 0)
        XCTAssertEqual(modifiedSession.photos.count, 1)
        XCTAssertFalse(originalSession.isComplete)
        XCTAssertTrue(modifiedSession.isComplete)
    }
}