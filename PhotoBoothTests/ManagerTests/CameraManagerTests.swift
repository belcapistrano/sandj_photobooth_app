import XCTest
import AVFoundation
import UIKit
@testable import com_bcaps_photobooth

class CameraManagerTests: XCTestCase {

    // MARK: - Test Properties

    var mockCameraManager: MockCameraManager!
    var cameraManager: CameraManager!

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
        mockCameraManager = MockCameraManager()
        cameraManager = CameraManager.shared
    }

    override func tearDown() {
        mockCameraManager.reset()
        mockCameraManager = nil
        cameraManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testCameraManagerSingleton() {
        // Test that CameraManager is a singleton
        let manager1 = CameraManager.shared
        let manager2 = CameraManager.shared

        XCTAssertTrue(manager1 === manager2, "CameraManager should be a singleton")
    }

    // MARK: - Mock CameraManager Tests

    func testMockCameraManagerInitialization() {
        // Test that mock camera manager initializes correctly
        XCTAssertNotNil(mockCameraManager)
        XCTAssertEqual(mockCameraManager.setupCameraCallCount, 0)
        XCTAssertEqual(mockCameraManager.capturePhotoCallCount, 0)
        XCTAssertFalse(mockCameraManager.lastFlashMode)
    }

    func testMockCameraManagerReset() {
        // Test that mock camera manager resets correctly
        mockCameraManager.setupCamera { _ in }
        mockCameraManager.capturePhoto { _ in }
        mockCameraManager.setFlashMode(true)

        XCTAssertGreaterThan(mockCameraManager.setupCameraCallCount, 0)
        XCTAssertGreaterThan(mockCameraManager.capturePhotoCallCount, 0)
        XCTAssertTrue(mockCameraManager.lastFlashMode)

        mockCameraManager.reset()

        XCTAssertEqual(mockCameraManager.setupCameraCallCount, 0)
        XCTAssertEqual(mockCameraManager.capturePhotoCallCount, 0)
        XCTAssertFalse(mockCameraManager.lastFlashMode)
    }

    // MARK: - Camera Setup Tests

    func testMockCameraSetupSuccess() {
        // Test successful camera setup
        let expectation = XCTestExpectation(description: "Camera setup completion")
        var setupResult: Result<AVCaptureVideoPreviewLayer, Error>?

        mockCameraManager.simulateSetupSuccess()
        mockCameraManager.setupCamera { result in
            setupResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        mockCameraManager.assertSetupCameraCalled()

        switch setupResult {
        case .success(let previewLayer):
            XCTAssertNotNil(previewLayer)
        case .failure(let error):
            XCTFail("Setup should not fail: \(error)")
        case .none:
            XCTFail("Setup completion should be called")
        }
    }

    func testMockCameraSetupFailure() {
        // Test camera setup failure
        let expectation = XCTestExpectation(description: "Camera setup failure")
        var setupResult: Result<AVCaptureVideoPreviewLayer, Error>?

        mockCameraManager.simulateSetupFailure()
        mockCameraManager.setupCamera { result in
            setupResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        mockCameraManager.assertSetupCameraCalled()

        switch setupResult {
        case .success:
            XCTFail("Setup should fail")
        case .failure(let error):
            XCTAssertNotNil(error)
        case .none:
            XCTFail("Setup completion should be called")
        }
    }

    func testMockCameraSetupPermissionDenied() {
        // Test camera setup with permission denied
        let expectation = XCTestExpectation(description: "Permission denied")
        var setupResult: Result<AVCaptureVideoPreviewLayer, Error>?

        mockCameraManager.simulatePermissionDenied()
        mockCameraManager.setupCamera { result in
            setupResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        switch setupResult {
        case .success:
            XCTFail("Setup should fail with permission denied")
        case .failure(let error):
            if let cameraError = error as? CameraError {
                XCTAssertEqual(cameraError, .permissionDenied)
            } else {
                XCTFail("Error should be CameraError.permissionDenied")
            }
        case .none:
            XCTFail("Setup completion should be called")
        }
    }

    func testMockCameraSetupDeviceNotFound() {
        // Test camera setup with device not found
        let expectation = XCTestExpectation(description: "Device not found")
        var setupResult: Result<AVCaptureVideoPreviewLayer, Error>?

        mockCameraManager.simulateDeviceNotFound()
        mockCameraManager.setupCamera { result in
            setupResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        switch setupResult {
        case .success:
            XCTFail("Setup should fail with device not found")
        case .failure(let error):
            if let cameraError = error as? CameraError {
                XCTAssertEqual(cameraError, .deviceNotFound)
            } else {
                XCTFail("Error should be CameraError.deviceNotFound")
            }
        case .none:
            XCTFail("Setup completion should be called")
        }
    }

    // MARK: - Session Management Tests

    func testMockCameraSessionStart() {
        // Test starting camera session
        mockCameraManager.startSession()
        mockCameraManager.assertStartSessionCalled()
    }

    func testMockCameraSessionStop() {
        // Test stopping camera session
        mockCameraManager.stopSession()
        mockCameraManager.assertStopSessionCalled()
    }

    func testMockCameraSessionStartStop() {
        // Test starting and stopping session
        mockCameraManager.startSession()
        mockCameraManager.stopSession()

        mockCameraManager.assertStartSessionCalled()
        mockCameraManager.assertStopSessionCalled()
    }

    func testMockCameraMultipleSessionOperations() {
        // Test multiple session operations
        mockCameraManager.startSession()
        mockCameraManager.startSession()
        mockCameraManager.stopSession()

        mockCameraManager.assertStartSessionCalled(times: 2)
        mockCameraManager.assertStopSessionCalled(times: 1)
    }

    // MARK: - Photo Capture Tests

    func testMockCameraPhotoCapture() {
        // Test successful photo capture
        let expectation = XCTestExpectation(description: "Photo capture")
        var captureResult: Result<UIImage, Error>?

        mockCameraManager.simulateCaptureSuccess()
        mockCameraManager.capturePhoto { result in
            captureResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        mockCameraManager.assertCapturePhotoCalled()

        switch captureResult {
        case .success(let image):
            XCTAssertNotNil(image)
        case .failure(let error):
            XCTFail("Capture should not fail: \(error)")
        case .none:
            XCTFail("Capture completion should be called")
        }
    }

    func testMockCameraPhotoCaptureFailure() {
        // Test photo capture failure
        let expectation = XCTestExpectation(description: "Photo capture failure")
        var captureResult: Result<UIImage, Error>?

        mockCameraManager.simulateCaptureFailure()
        mockCameraManager.capturePhoto { result in
            captureResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        mockCameraManager.assertCapturePhotoCalled()

        switch captureResult {
        case .success:
            XCTFail("Capture should fail")
        case .failure(let error):
            XCTAssertNotNil(error)
        case .none:
            XCTFail("Capture completion should be called")
        }
    }

    func testMockCameraImageProcessingFailure() {
        // Test image processing failure
        let expectation = XCTestExpectation(description: "Image processing failure")
        var captureResult: Result<UIImage, Error>?

        mockCameraManager.simulateImageProcessingFailure()
        mockCameraManager.capturePhoto { result in
            captureResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        switch captureResult {
        case .success:
            XCTFail("Capture should fail with image processing error")
        case .failure(let error):
            if let cameraError = error as? CameraError {
                XCTAssertEqual(cameraError, .imageProcessingFailed)
            } else {
                XCTFail("Error should be CameraError.imageProcessingFailed")
            }
        case .none:
            XCTFail("Capture completion should be called")
        }
    }

    func testMockCameraMultipleCaptures() {
        // Test multiple photo captures
        let expectation1 = XCTestExpectation(description: "First capture")
        let expectation2 = XCTestExpectation(description: "Second capture")
        let expectation3 = XCTestExpectation(description: "Third capture")

        mockCameraManager.simulateMultipleQuickCaptures()

        mockCameraManager.capturePhoto { _ in expectation1.fulfill() }
        mockCameraManager.capturePhoto { _ in expectation2.fulfill() }
        mockCameraManager.capturePhoto { _ in expectation3.fulfill() }

        wait(for: [expectation1, expectation2, expectation3], timeout: 1.0)

        mockCameraManager.assertCapturePhotoCalled(times: 3)
    }

    // MARK: - Camera Switching Tests

    func testMockCameraSwitching() {
        // Test camera switching
        mockCameraManager.simulateSwitchSuccess()
        mockCameraManager.switchCamera()

        mockCameraManager.assertSwitchCameraCalled()
    }

    func testMockCameraSwitchingFailure() {
        // Test camera switching failure
        mockCameraManager.simulateSwitchFailure()
        mockCameraManager.switchCamera()

        mockCameraManager.assertSwitchCameraCalled()
    }

    func testMockCameraMultipleSwitches() {
        // Test multiple camera switches
        mockCameraManager.switchCamera()
        mockCameraManager.switchCamera()
        mockCameraManager.switchCamera()

        mockCameraManager.assertSwitchCameraCalled(times: 3)
    }

    // MARK: - Flash Tests

    func testMockCameraFlashMode() {
        // Test setting flash mode
        mockCameraManager.setFlashMode(true)
        mockCameraManager.assertSetFlashModeCalled()
        mockCameraManager.assertFlashMode(true)

        mockCameraManager.setFlashMode(false)
        mockCameraManager.assertSetFlashModeCalled(times: 2)
        mockCameraManager.assertFlashMode(false)
    }

    func testMockCameraToggleFlash() {
        // Test toggling flash
        XCTAssertFalse(mockCameraManager.lastFlashMode) // Initial state

        mockCameraManager.toggleFlash()
        mockCameraManager.assertToggleFlashCalled()
        mockCameraManager.assertFlashMode(true)

        mockCameraManager.toggleFlash()
        mockCameraManager.assertToggleFlashCalled(times: 2)
        mockCameraManager.assertFlashMode(false)
    }

    func testMockCameraFlashModeAndToggle() {
        // Test combination of setting and toggling flash
        mockCameraManager.setFlashMode(true)
        mockCameraManager.assertFlashMode(true)

        mockCameraManager.toggleFlash()
        mockCameraManager.assertFlashMode(false)

        mockCameraManager.toggleFlash()
        mockCameraManager.assertFlashMode(true)
    }

    // MARK: - Performance Tests

    func testMockCameraManagerPerformance() {
        // Test mock camera manager performance
        measure {
            for _ in 0..<1000 {
                mockCameraManager.startSession()
                mockCameraManager.stopSession()
                mockCameraManager.switchCamera()
                mockCameraManager.setFlashMode(true)
                mockCameraManager.toggleFlash()
            }
        }
    }

    func testMockCameraSetupPerformance() {
        // Test camera setup performance
        mockCameraManager.simulateSetupSuccess()

        measure {
            for i in 0..<100 {
                let expectation = XCTestExpectation(description: "Setup \(i)")
                mockCameraManager.setupCamera { _ in
                    expectation.fulfill()
                }
                wait(for: [expectation], timeout: 0.1)
            }
        }
    }

    // MARK: - Async Tests

    func testMockCameraAsyncOperations() {
        // Test asynchronous operations
        let setupExpectation = XCTestExpectation(description: "Async setup")
        let captureExpectation = XCTestExpectation(description: "Async capture")

        mockCameraManager.simulateRealWorldCameraSetup()

        mockCameraManager.setupCamera { result in
            switch result {
            case .success:
                setupExpectation.fulfill()
            case .failure(let error):
                XCTFail("Setup should succeed: \(error)")
            }
        }

        wait(for: [setupExpectation], timeout: 1.0)

        mockCameraManager.capturePhoto { result in
            switch result {
            case .success:
                captureExpectation.fulfill()
            case .failure(let error):
                XCTFail("Capture should succeed: \(error)")
            }
        }

        wait(for: [captureExpectation], timeout: 1.0)
    }

    func testMockCameraSlowOperations() {
        // Test slow camera operations
        let expectation = XCTestExpectation(description: "Slow camera")

        mockCameraManager.simulateSlowCamera()
        mockCameraManager.setupCamera { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
        mockCameraManager.assertSetupCameraCalled()
    }

    // MARK: - Error Handling Tests

    func testMockCameraErrorTypes() {
        // Test different error types
        let errors: [CameraError] = [
            .permissionDenied,
            .deviceNotFound,
            .inputError,
            .outputError,
            .imageProcessingFailed
        ]

        for (index, error) in errors.enumerated() {
            let expectation = XCTestExpectation(description: "Error \(index)")
            var capturedError: Error?

            mockCameraManager.simulateSetupFailure(error: error)
            mockCameraManager.setupCamera { result in
                switch result {
                case .success:
                    XCTFail("Should fail with \(error)")
                case .failure(let err):
                    capturedError = err
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)

            if let cameraError = capturedError as? CameraError {
                XCTAssertEqual(cameraError, error)
            } else {
                XCTFail("Error should be CameraError")
            }

            mockCameraManager.reset()
        }
    }

    func testMockCameraMemoryPressure() {
        // Test memory pressure scenario
        let expectation = XCTestExpectation(description: "Memory pressure")
        var captureResult: Result<UIImage, Error>?

        mockCameraManager.simulateMemoryPressure()
        mockCameraManager.capturePhoto { result in
            captureResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        switch captureResult {
        case .success:
            XCTFail("Capture should fail under memory pressure")
        case .failure(let error):
            XCTAssertTrue(error.localizedDescription.contains("Memory"))
        case .none:
            XCTFail("Capture completion should be called")
        }
    }

    // MARK: - Real-world Scenario Tests

    func testMockCameraTypicalUsageFlow() {
        // Test typical camera usage flow
        let setupExpectation = XCTestExpectation(description: "Setup")
        let captureExpectation = XCTestExpectation(description: "Capture")

        mockCameraManager.simulateRealWorldCameraSetup()

        // 1. Setup camera
        mockCameraManager.setupCamera { result in
            switch result {
            case .success:
                setupExpectation.fulfill()
            case .failure(let error):
                XCTFail("Setup failed: \(error)")
            }
        }

        wait(for: [setupExpectation], timeout: 1.0)

        // 2. Start session
        mockCameraManager.startSession()

        // 3. Capture photo
        mockCameraManager.capturePhoto { result in
            switch result {
            case .success:
                captureExpectation.fulfill()
            case .failure(let error):
                XCTFail("Capture failed: \(error)")
            }
        }

        wait(for: [captureExpectation], timeout: 1.0)

        // 4. Stop session
        mockCameraManager.stopSession()

        // Verify all operations were called
        mockCameraManager.assertSetupCameraCalled()
        mockCameraManager.assertStartSessionCalled()
        mockCameraManager.assertCapturePhotoCalled()
        mockCameraManager.assertStopSessionCalled()
    }

    func testMockCameraPhotoshootFlow() {
        // Test multiple photo capture flow
        let expectations = (0..<5).map { XCTestExpectation(description: "Capture \($0)") }

        mockCameraManager.simulateMultipleQuickCaptures()

        for (index, expectation) in expectations.enumerated() {
            mockCameraManager.capturePhoto { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Capture \(index) failed: \(error)")
                }
            }
        }

        wait(for: expectations, timeout: 1.0)
        mockCameraManager.assertCapturePhotoCalled(times: 5)
    }

    // MARK: - Edge Cases

    func testMockCameraNoCallsInitially() {
        // Test that no calls are made initially
        mockCameraManager.assertNoCalls()
    }

    func testMockCameraResetClearsState() {
        // Test that reset clears all state
        mockCameraManager.setupCamera { _ in }
        mockCameraManager.capturePhoto { _ in }
        mockCameraManager.setFlashMode(true)

        XCTAssertGreaterThan(mockCameraManager.setupCameraCallCount, 0)
        XCTAssertGreaterThan(mockCameraManager.capturePhotoCallCount, 0)
        XCTAssertTrue(mockCameraManager.lastFlashMode)

        mockCameraManager.reset()
        mockCameraManager.assertNoCalls()
        mockCameraManager.assertFlashMode(false)
    }
}