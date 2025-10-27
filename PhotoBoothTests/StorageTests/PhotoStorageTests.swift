import XCTest
import UIKit
import Foundation
@testable import com_bcaps_photobooth

class PhotoStorageTests: XCTestCase {

    // MARK: - Test Properties

    var photoStorage: PhotoStorage!
    var testDirectory: URL!

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
        photoStorage = PhotoStorage.shared

        // Create test directory
        do {
            try TestHelpers.createTestDirectory()
            testDirectory = TestHelpers.getTestDocumentsDirectory()
        } catch {
            XCTFail("Failed to create test directory: \(error)")
        }
    }

    override func tearDown() {
        // Clean up test files
        TestHelpers.cleanupTestFiles()
        photoStorage = nil
        testDirectory = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testPhotoStorageSingleton() {
        // Test that PhotoStorage is a singleton
        let storage1 = PhotoStorage.shared
        let storage2 = PhotoStorage.shared

        XCTAssertTrue(storage1 === storage2, "PhotoStorage should be a singleton")
    }

    // MARK: - Save Photo Tests

    func testSavePhotoSuccess() {
        // Test successful photo saving
        let testImage = TestHelpers.createTestImage(color: .blue, size: CGSize(width: 200, height: 200))
        let photoId = UUID()

        do {
            let savedURL = try photoStorage.savePhoto(testImage, id: photoId)

            XCTAssertNotNil(savedURL)
            XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))
            XCTAssertTrue(savedURL.absoluteString.contains(photoId.uuidString))
            XCTAssertTrue(savedURL.pathExtension == "jpg")
        } catch {
            XCTFail("Save photo should succeed: \(error)")
        }
    }

    func testSavePhotoCreatesCorrectFilename() {
        // Test that saved photo has correct filename
        let testImage = TestHelpers.createTestImage()
        let photoId = UUID()

        do {
            let savedURL = try photoStorage.savePhoto(testImage, id: photoId)
            let expectedFilename = "\(photoId.uuidString).jpg"

            XCTAssertEqual(savedURL.lastPathComponent, expectedFilename)
        } catch {
            XCTFail("Save photo should succeed: \(error)")
        }
    }

    func testSaveMultiplePhotos() {
        // Test saving multiple photos
        let testImages = [
            TestHelpers.createTestImage(color: .red),
            TestHelpers.createTestImage(color: .green),
            TestHelpers.createTestImage(color: .blue)
        ]
        let photoIds = [UUID(), UUID(), UUID()]

        var savedURLs: [URL] = []

        for (image, id) in zip(testImages, photoIds) {
            do {
                let savedURL = try photoStorage.savePhoto(image, id: id)
                savedURLs.append(savedURL)
            } catch {
                XCTFail("Save photo should succeed: \(error)")
            }
        }

        XCTAssertEqual(savedURLs.count, 3)

        // Verify all files exist
        for url in savedURLs {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testSavePhotoOverwritesExisting() {
        // Test that saving with same ID overwrites existing file
        let photoId = UUID()
        let originalImage = TestHelpers.createTestImage(color: .red)
        let newImage = TestHelpers.createTestImage(color: .blue)

        do {
            // Save original
            let originalURL = try photoStorage.savePhoto(originalImage, id: photoId)
            let originalData = try Data(contentsOf: originalURL)

            // Save new image with same ID
            let newURL = try photoStorage.savePhoto(newImage, id: photoId)
            let newData = try Data(contentsOf: newURL)

            XCTAssertEqual(originalURL, newURL) // Same URL
            XCTAssertNotEqual(originalData, newData) // Different data
        } catch {
            XCTFail("Save operations should succeed: \(error)")
        }
    }

    // MARK: - Load Photo Tests

    func testLoadPhotoSuccess() {
        // Test successful photo loading
        let testImage = TestHelpers.createTestImage(color: .green, size: CGSize(width: 150, height: 150))
        let photoId = UUID()

        do {
            // Save photo first
            _ = try photoStorage.savePhoto(testImage, id: photoId)

            // Load photo
            let loadedImage = photoStorage.loadPhoto(id: photoId)

            XCTAssertNotNil(loadedImage)
            XCTAssertEqual(loadedImage?.size.width, testImage.size.width, accuracy: 1.0)
            XCTAssertEqual(loadedImage?.size.height, testImage.size.height, accuracy: 1.0)
        } catch {
            XCTFail("Save and load should succeed: \(error)")
        }
    }

    func testLoadNonexistentPhoto() {
        // Test loading photo that doesn't exist
        let nonExistentId = UUID()
        let loadedImage = photoStorage.loadPhoto(id: nonExistentId)

        XCTAssertNil(loadedImage)
    }

    func testLoadPhotoAfterSaveAndDelete() {
        // Test loading photo after it's been deleted
        let testImage = TestHelpers.createTestImage()
        let photoId = UUID()

        do {
            // Save photo
            _ = try photoStorage.savePhoto(testImage, id: photoId)

            // Verify it exists
            let loadedImage1 = photoStorage.loadPhoto(id: photoId)
            XCTAssertNotNil(loadedImage1)

            // Delete photo
            try photoStorage.deletePhoto(id: photoId)

            // Try to load again
            let loadedImage2 = photoStorage.loadPhoto(id: photoId)
            XCTAssertNil(loadedImage2)
        } catch {
            XCTFail("Operations should succeed: \(error)")
        }
    }

    func testLoadMultiplePhotos() {
        // Test loading multiple photos
        let testImages = [
            TestHelpers.createTestImage(color: .red),
            TestHelpers.createTestImage(color: .green),
            TestHelpers.createTestImage(color: .blue)
        ]
        let photoIds = [UUID(), UUID(), UUID()]

        // Save all photos
        for (image, id) in zip(testImages, photoIds) {
            do {
                _ = try photoStorage.savePhoto(image, id: id)
            } catch {
                XCTFail("Save should succeed: \(error)")
            }
        }

        // Load all photos
        let loadedImages = photoIds.compactMap { photoStorage.loadPhoto(id: $0) }

        XCTAssertEqual(loadedImages.count, 3)
    }

    // MARK: - Delete Photo Tests

    func testDeletePhotoSuccess() {
        // Test successful photo deletion
        let testImage = TestHelpers.createTestImage()
        let photoId = UUID()

        do {
            // Save photo first
            let savedURL = try photoStorage.savePhoto(testImage, id: photoId)
            XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))

            // Delete photo
            try photoStorage.deletePhoto(id: photoId)
            XCTAssertFalse(FileManager.default.fileExists(atPath: savedURL.path))
        } catch {
            XCTFail("Save and delete should succeed: \(error)")
        }
    }

    func testDeleteNonexistentPhoto() {
        // Test deleting photo that doesn't exist
        let nonExistentId = UUID()

        XCTAssertThrowsError(try photoStorage.deletePhoto(id: nonExistentId)) { error in
            // Should throw an error when trying to delete non-existent file
            XCTAssertNotNil(error)
        }
    }

    func testDeleteMultiplePhotos() {
        // Test deleting multiple photos
        let testImages = [
            TestHelpers.createTestImage(color: .red),
            TestHelpers.createTestImage(color: .green),
            TestHelpers.createTestImage(color: .blue)
        ]
        let photoIds = [UUID(), UUID(), UUID()]

        // Save all photos
        var savedURLs: [URL] = []
        for (image, id) in zip(testImages, photoIds) {
            do {
                let savedURL = try photoStorage.savePhoto(image, id: id)
                savedURLs.append(savedURL)
            } catch {
                XCTFail("Save should succeed: \(error)")
            }
        }

        // Verify all exist
        for url in savedURLs {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }

        // Delete all photos
        for id in photoIds {
            do {
                try photoStorage.deletePhoto(id: id)
            } catch {
                XCTFail("Delete should succeed: \(error)")
            }
        }

        // Verify all are deleted
        for url in savedURLs {
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        }
    }

    // MARK: - Get All Photo URLs Tests

    func testGetAllPhotoURLsEmpty() {
        // Test getting URLs when no photos exist
        TestHelpers.cleanupTestFiles()
        let urls = photoStorage.getAllPhotoURLs()

        XCTAssertTrue(urls.isEmpty)
    }

    func testGetAllPhotoURLsWithPhotos() {
        // Test getting URLs when photos exist
        let testImages = [
            TestHelpers.createTestImage(color: .red),
            TestHelpers.createTestImage(color: .green),
            TestHelpers.createTestImage(color: .blue)
        ]
        let photoIds = [UUID(), UUID(), UUID()]

        // Save photos
        for (image, id) in zip(testImages, photoIds) {
            do {
                _ = try photoStorage.savePhoto(image, id: id)
            } catch {
                XCTFail("Save should succeed: \(error)")
            }
        }

        let urls = photoStorage.getAllPhotoURLs()

        XCTAssertEqual(urls.count, 3)
        for url in urls {
            XCTAssertEqual(url.pathExtension, "jpg")
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testGetAllPhotoURLsFiltering() {
        // Test that getAllPhotoURLs only returns .jpg files
        let testImage = TestHelpers.createTestImage()
        let photoId = UUID()

        do {
            // Save a photo
            _ = try photoStorage.savePhoto(testImage, id: photoId)

            // Create a non-jpg file in the same directory
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let txtFileURL = documentsDir.appendingPathComponent("test.txt")
            try "test content".write(to: txtFileURL, atomically: true, encoding: .utf8)

            let urls = photoStorage.getAllPhotoURLs()

            // Should only return the .jpg file, not the .txt file
            XCTAssertEqual(urls.count, 1)
            XCTAssertEqual(urls.first?.pathExtension, "jpg")
        } catch {
            XCTFail("Operations should succeed: \(error)")
        }
    }

    // MARK: - Error Handling Tests

    func testSavePhotoWithInvalidImage() {
        // Test saving invalid image data
        // Note: In practice, UIImage usually won't fail JPEG compression,
        // but we can test the error path
        let photoId = UUID()

        // Create a very small image that might cause compression issues
        let smallImage = TestHelpers.createTestImage(size: CGSize(width: 1, height: 1))

        do {
            _ = try photoStorage.savePhoto(smallImage, id: photoId)
            // If this succeeds, that's fine - JPEG compression is robust
        } catch let error as StorageError {
            XCTAssertEqual(error, .compressionFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Performance Tests

    func testSavePhotoPerformance() {
        // Test photo saving performance
        let testImages = (0..<10).map { _ in
            TestHelpers.createTestImage(size: CGSize(width: 100, height: 100))
        }
        let photoIds = (0..<10).map { _ in UUID() }

        measure {
            for (image, id) in zip(testImages, photoIds) {
                do {
                    _ = try photoStorage.savePhoto(image, id: id)
                } catch {
                    XCTFail("Save should succeed: \(error)")
                }
            }
        }

        // Cleanup
        for id in photoIds {
            try? photoStorage.deletePhoto(id: id)
        }
    }

    func testLoadPhotoPerformance() {
        // Test photo loading performance
        let testImages = (0..<10).map { _ in
            TestHelpers.createTestImage(size: CGSize(width: 100, height: 100))
        }
        let photoIds = (0..<10).map { _ in UUID() }

        // Save photos first
        for (image, id) in zip(testImages, photoIds) {
            do {
                _ = try photoStorage.savePhoto(image, id: id)
            } catch {
                XCTFail("Save should succeed: \(error)")
            }
        }

        measure {
            for id in photoIds {
                _ = photoStorage.loadPhoto(id: id)
            }
        }

        // Cleanup
        for id in photoIds {
            try? photoStorage.deletePhoto(id: id)
        }
    }

    func testGetAllPhotoURLsPerformance() {
        // Test getAllPhotoURLs performance with many files
        let testImages = (0..<50).map { _ in
            TestHelpers.createTestImage(size: CGSize(width: 50, height: 50))
        }
        let photoIds = (0..<50).map { _ in UUID() }

        // Save photos first
        for (image, id) in zip(testImages, photoIds) {
            do {
                _ = try photoStorage.savePhoto(image, id: id)
            } catch {
                XCTFail("Save should succeed: \(error)")
            }
        }

        measure {
            _ = photoStorage.getAllPhotoURLs()
        }

        // Cleanup
        for id in photoIds {
            try? photoStorage.deletePhoto(id: id)
        }
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentSaveOperations() {
        // Test concurrent save operations
        let expectation = XCTestExpectation(description: "Concurrent saves")
        expectation.expectedFulfillmentCount = 5

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        for i in 0..<5 {
            queue.async {
                let testImage = TestHelpers.createTestImage(color: .red)
                let photoId = UUID()

                do {
                    _ = try self.photoStorage.savePhoto(testImage, id: photoId)
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent save \(i) failed: \(error)")
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testConcurrentLoadOperations() {
        // Test concurrent load operations
        let testImage = TestHelpers.createTestImage()
        let photoIds = (0..<5).map { _ in UUID() }

        // Save photos first
        for id in photoIds {
            do {
                _ = try photoStorage.savePhoto(testImage, id: id)
            } catch {
                XCTFail("Save should succeed: \(error)")
            }
        }

        let expectation = XCTestExpectation(description: "Concurrent loads")
        expectation.expectedFulfillmentCount = 5

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        for (i, id) in photoIds.enumerated() {
            queue.async {
                let loadedImage = self.photoStorage.loadPhoto(id: id)
                if loadedImage != nil {
                    expectation.fulfill()
                } else {
                    XCTFail("Concurrent load \(i) failed")
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // Cleanup
        for id in photoIds {
            try? photoStorage.deletePhoto(id: id)
        }
    }

    // MARK: - Memory Tests

    func testMemoryUsageWithLargeImages() {
        // Test memory usage with large images
        let largeImages = (0..<5).map { _ in
            TestHelpers.createTestImage(size: CGSize(width: 1000, height: 1000))
        }
        let photoIds = (0..<5).map { _ in UUID() }

        let (_, memoryUsed) = TestHelpers.measureMemoryUsage {
            for (image, id) in zip(largeImages, photoIds) {
                do {
                    _ = try photoStorage.savePhoto(image, id: id)
                } catch {
                    XCTFail("Save should succeed: \(error)")
                }
            }
        }

        // Memory usage should be reasonable even with large images
        XCTAssertLessThan(memoryUsed, 50 * 1024 * 1024) // Less than 50MB

        // Cleanup
        for id in photoIds {
            try? photoStorage.deletePhoto(id: id)
        }
    }

    // MARK: - Real-world Scenario Tests

    func testPhotographySessionScenario() {
        // Test realistic photography session scenario
        let numberOfPhotos = 10
        var savedPhotoIds: [UUID] = []

        // Take multiple photos
        for i in 0..<numberOfPhotos {
            let testImage = TestHelpers.createTestImage(
                color: [UIColor.red, .green, .blue, .yellow, .purple][i % 5],
                size: CGSize(width: 200, height: 300)
            )
            let photoId = UUID()

            do {
                _ = try photoStorage.savePhoto(testImage, id: photoId)
                savedPhotoIds.append(photoId)
            } catch {
                XCTFail("Photo \(i) save failed: \(error)")
            }
        }

        // Verify all photos were saved
        XCTAssertEqual(savedPhotoIds.count, numberOfPhotos)

        // Get all photo URLs
        let allURLs = photoStorage.getAllPhotoURLs()
        XCTAssertGreaterThanOrEqual(allURLs.count, numberOfPhotos)

        // Load a few random photos
        let randomIndices = [0, 3, 7, 9]
        for index in randomIndices {
            let photoId = savedPhotoIds[index]
            let loadedImage = photoStorage.loadPhoto(id: photoId)
            XCTAssertNotNil(loadedImage, "Photo \(index) should load successfully")
        }

        // Delete some photos
        let photosToDelete = Array(savedPhotoIds.prefix(5))
        for photoId in photosToDelete {
            do {
                try photoStorage.deletePhoto(id: photoId)
            } catch {
                XCTFail("Delete should succeed: \(error)")
            }
        }

        // Verify remaining photos still exist
        let remainingPhotos = Array(savedPhotoIds.suffix(5))
        for photoId in remainingPhotos {
            let loadedImage = photoStorage.loadPhoto(id: photoId)
            XCTAssertNotNil(loadedImage, "Remaining photo should still exist")
        }

        // Cleanup remaining photos
        for photoId in remainingPhotos {
            try? photoStorage.deletePhoto(id: photoId)
        }
    }

    // MARK: - Edge Cases

    func testSavePhotoWithEmptyImage() {
        // Test saving very small/empty image
        let emptyImage = TestHelpers.createTestImage(size: CGSize(width: 0, height: 0))
        let photoId = UUID()

        // This might succeed or fail depending on implementation
        do {
            _ = try photoStorage.savePhoto(emptyImage, id: photoId)
            // If it succeeds, cleanup
            try? photoStorage.deletePhoto(id: photoId)
        } catch {
            // If it fails, that's also acceptable for edge case
            XCTAssertTrue(error is StorageError)
        }
    }

    func testSavePhotoWithSameIdMultipleTimes() {
        // Test overwriting the same photo multiple times
        let photoId = UUID()
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple]

        for (index, color) in colors.enumerated() {
            let testImage = TestHelpers.createTestImage(color: color)

            do {
                _ = try photoStorage.savePhoto(testImage, id: photoId)
            } catch {
                XCTFail("Save \(index) should succeed: \(error)")
            }
        }

        // Should only have one file with this ID
        let loadedImage = photoStorage.loadPhoto(id: photoId)
        XCTAssertNotNil(loadedImage)

        // Cleanup
        try? photoStorage.deletePhoto(id: photoId)
    }
}