import XCTest
import Foundation
@testable import com_bcaps_photobooth

class StorageErrorTests: XCTestCase {

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Error Cases Tests

    func testStorageErrorCases() {
        // Test that all expected error cases exist
        let compressionError = StorageError.compressionFailed
        let fileNotFoundError = StorageError.fileNotFound
        let writeFailedError = StorageError.writeFailed
        let readFailedError = StorageError.readFailed
        let invalidDataError = StorageError.invalidData

        XCTAssertNotNil(compressionError)
        XCTAssertNotNil(fileNotFoundError)
        XCTAssertNotNil(writeFailedError)
        XCTAssertNotNil(readFailedError)
        XCTAssertNotNil(invalidDataError)
    }

    func testStorageErrorEquality() {
        // Test that same error cases are equal
        XCTAssertEqual(StorageError.compressionFailed, StorageError.compressionFailed)
        XCTAssertEqual(StorageError.fileNotFound, StorageError.fileNotFound)
        XCTAssertEqual(StorageError.writeFailed, StorageError.writeFailed)
        XCTAssertEqual(StorageError.readFailed, StorageError.readFailed)
        XCTAssertEqual(StorageError.invalidData, StorageError.invalidData)
    }

    func testStorageErrorInequality() {
        // Test that different error cases are not equal
        XCTAssertNotEqual(StorageError.compressionFailed, StorageError.fileNotFound)
        XCTAssertNotEqual(StorageError.fileNotFound, StorageError.writeFailed)
        XCTAssertNotEqual(StorageError.writeFailed, StorageError.readFailed)
        XCTAssertNotEqual(StorageError.readFailed, StorageError.invalidData)
        XCTAssertNotEqual(StorageError.invalidData, StorageError.compressionFailed)
    }

    // MARK: - LocalizedError Tests

    func testStorageErrorDescriptions() {
        // Test that all errors have proper descriptions
        let errors: [StorageError] = [
            .compressionFailed,
            .fileNotFound,
            .writeFailed,
            .readFailed,
            .invalidData
        ]

        for error in errors {
            let description = error.errorDescription
            XCTAssertNotNil(description, "Error \(error) should have a description")
            XCTAssertFalse(description!.isEmpty, "Error description should not be empty")
        }
    }

    func testCompressionFailedDescription() {
        // Test specific error description
        let error = StorageError.compressionFailed
        let description = error.errorDescription

        XCTAssertEqual(description, "Failed to compress image data")
    }

    func testFileNotFoundDescription() {
        // Test specific error description
        let error = StorageError.fileNotFound
        let description = error.errorDescription

        XCTAssertEqual(description, "File not found")
    }

    func testWriteFailedDescription() {
        // Test specific error description
        let error = StorageError.writeFailed
        let description = error.errorDescription

        XCTAssertEqual(description, "Failed to write data to file")
    }

    func testReadFailedDescription() {
        // Test specific error description
        let error = StorageError.readFailed
        let description = error.errorDescription

        XCTAssertEqual(description, "Failed to read data from file")
    }

    func testInvalidDataDescription() {
        // Test specific error description
        let error = StorageError.invalidData
        let description = error.errorDescription

        XCTAssertEqual(description, "Invalid data format")
    }

    // MARK: - Error Protocol Conformance Tests

    func testStorageErrorAsError() {
        // Test that StorageError can be used as Error
        let storageError: StorageError = .compressionFailed
        let error: Error = storageError

        XCTAssertNotNil(error)
        XCTAssertTrue(error is StorageError)
    }

    func testStorageErrorLocalizedDescription() {
        // Test that localizedDescription works
        let error = StorageError.compressionFailed
        let localizedDescription = error.localizedDescription

        XCTAssertFalse(localizedDescription.isEmpty)
        XCTAssertEqual(localizedDescription, "Failed to compress image data")
    }

    // MARK: - Error Handling Tests

    func testStorageErrorInThrowingFunction() {
        // Test using StorageError in throwing functions
        func throwCompressionError() throws {
            throw StorageError.compressionFailed
        }

        func throwFileNotFoundError() throws {
            throw StorageError.fileNotFound
        }

        XCTAssertThrowsError(try throwCompressionError()) { error in
            XCTAssertTrue(error is StorageError)
            XCTAssertEqual(error as? StorageError, .compressionFailed)
        }

        XCTAssertThrowsError(try throwFileNotFoundError()) { error in
            XCTAssertTrue(error is StorageError)
            XCTAssertEqual(error as? StorageError, .fileNotFound)
        }
    }

    func testStorageErrorInResultType() {
        // Test using StorageError with Result type
        func successResult() -> Result<String, StorageError> {
            return .success("Success")
        }

        func failureResult() -> Result<String, StorageError> {
            return .failure(.readFailed)
        }

        let success = successResult()
        let failure = failureResult()

        switch success {
        case .success(let value):
            XCTAssertEqual(value, "Success")
        case .failure:
            XCTFail("Should not fail")
        }

        switch failure {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, .readFailed)
        }
    }

    // MARK: - Error Categories Tests

    func testCompressionRelatedErrors() {
        // Test compression-related errors
        let compressionError = StorageError.compressionFailed

        XCTAssertEqual(compressionError, .compressionFailed)
        XCTAssertTrue(compressionError.errorDescription?.contains("compress") == true)
    }

    func testFileSystemRelatedErrors() {
        // Test file system-related errors
        let fileErrors: [StorageError] = [.fileNotFound, .writeFailed, .readFailed]

        for error in fileErrors {
            let description = error.errorDescription ?? ""
            XCTAssertTrue(
                description.contains("file") ||
                description.contains("write") ||
                description.contains("read") ||
                description.contains("File")
            )
        }
    }

    func testDataRelatedErrors() {
        // Test data-related errors
        let dataError = StorageError.invalidData

        XCTAssertEqual(dataError, .invalidData)
        XCTAssertTrue(dataError.errorDescription?.contains("data") == true)
    }

    // MARK: - Switch Statement Tests

    func testStorageErrorSwitchStatement() {
        // Test that all cases can be handled in switch statement
        let errors: [StorageError] = [
            .compressionFailed,
            .fileNotFound,
            .writeFailed,
            .readFailed,
            .invalidData
        ]

        for error in errors {
            var handled = false

            switch error {
            case .compressionFailed:
                handled = true
            case .fileNotFound:
                handled = true
            case .writeFailed:
                handled = true
            case .readFailed:
                handled = true
            case .invalidData:
                handled = true
            }

            XCTAssertTrue(handled, "Error \(error) should be handled")
        }
    }

    // MARK: - Error Categorization Helper Tests

    func testErrorCategorizationHelpers() {
        // Test helper methods for error categorization (if any exist)
        func isFileSystemError(_ error: StorageError) -> Bool {
            switch error {
            case .fileNotFound, .writeFailed, .readFailed:
                return true
            case .compressionFailed, .invalidData:
                return false
            }
        }

        func isDataProcessingError(_ error: StorageError) -> Bool {
            switch error {
            case .compressionFailed, .invalidData:
                return true
            case .fileNotFound, .writeFailed, .readFailed:
                return false
            }
        }

        XCTAssertTrue(isFileSystemError(.fileNotFound))
        XCTAssertTrue(isFileSystemError(.writeFailed))
        XCTAssertTrue(isFileSystemError(.readFailed))
        XCTAssertFalse(isFileSystemError(.compressionFailed))
        XCTAssertFalse(isFileSystemError(.invalidData))

        XCTAssertTrue(isDataProcessingError(.compressionFailed))
        XCTAssertTrue(isDataProcessingError(.invalidData))
        XCTAssertFalse(isDataProcessingError(.fileNotFound))
        XCTAssertFalse(isDataProcessingError(.writeFailed))
        XCTAssertFalse(isDataProcessingError(.readFailed))
    }

    // MARK: - Performance Tests

    func testStorageErrorPerformance() {
        // Test that error creation and handling is fast
        measure {
            for _ in 0..<10000 {
                let error = StorageError.compressionFailed
                _ = error.errorDescription
            }
        }
    }

    func testStorageErrorSwitchPerformance() {
        // Test that switch statements on errors are fast
        let errors: [StorageError] = Array(repeating: [
            .compressionFailed, .fileNotFound, .writeFailed, .readFailed, .invalidData
        ], count: 200).flatMap { $0 }

        measure {
            for error in errors {
                switch error {
                case .compressionFailed:
                    break
                case .fileNotFound:
                    break
                case .writeFailed:
                    break
                case .readFailed:
                    break
                case .invalidData:
                    break
                }
            }
        }
    }

    // MARK: - Real-world Usage Tests

    func testStorageErrorInErrorHandler() {
        // Test using StorageError with error handler pattern
        func handleStorageError(_ error: StorageError) -> String {
            switch error {
            case .compressionFailed:
                return "Try reducing image quality"
            case .fileNotFound:
                return "File may have been deleted"
            case .writeFailed:
                return "Check available storage space"
            case .readFailed:
                return "File may be corrupted"
            case .invalidData:
                return "Data format is not supported"
            }
        }

        let suggestions = [
            StorageError.compressionFailed: "Try reducing image quality",
            StorageError.fileNotFound: "File may have been deleted",
            StorageError.writeFailed: "Check available storage space",
            StorageError.readFailed: "File may be corrupted",
            StorageError.invalidData: "Data format is not supported"
        ]

        for (error, expectedSuggestion) in suggestions {
            let suggestion = handleStorageError(error)
            XCTAssertEqual(suggestion, expectedSuggestion)
        }
    }

    func testStorageErrorInLogging() {
        // Test using StorageError for logging
        func logError(_ error: StorageError, context: String) -> String {
            return "[\(context)] \(error.errorDescription ?? "Unknown error")"
        }

        let logMessage = logError(.compressionFailed, context: "PhotoStorage")
        XCTAssertEqual(logMessage, "[PhotoStorage] Failed to compress image data")

        let logMessage2 = logError(.fileNotFound, context: "SessionStorage")
        XCTAssertEqual(logMessage2, "[SessionStorage] File not found")
    }

    // MARK: - Memory Tests

    func testStorageErrorMemoryUsage() {
        // Test that errors don't use excessive memory
        let (errors, memoryUsed) = TestHelpers.measureMemoryUsage {
            return (0..<10000).map { i in
                let errorTypes: [StorageError] = [.compressionFailed, .fileNotFound, .writeFailed, .readFailed, .invalidData]
                return errorTypes[i % errorTypes.count]
            }
        }

        XCTAssertEqual(errors.count, 10000)
        // Errors should use minimal memory (they're just enums)
        XCTAssertLessThan(memoryUsed, 1024 * 1024) // Less than 1MB for 10000 errors
    }
}