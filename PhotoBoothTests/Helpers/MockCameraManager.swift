import Foundation
import UIKit
import AVFoundation
@testable import com_bcaps_photobooth

class MockCameraManager {

    // MARK: - Mock State

    var setupCameraCallCount = 0
    var startSessionCallCount = 0
    var stopSessionCallCount = 0
    var capturePhotoCallCount = 0
    var switchCameraCallCount = 0
    var setFlashModeCallCount = 0
    var toggleFlashCallCount = 0

    // MARK: - Mock Configuration

    var shouldSimulateSetupFailure = false
    var shouldSimulateCaptureFailure = false
    var shouldSimulateSwitchFailure = false
    var setupDelay: TimeInterval = 0
    var captureDelay: TimeInterval = 0

    var mockPreviewLayer: AVCaptureVideoPreviewLayer?
    var mockCapturedImage: UIImage?
    var mockError: Error?

    // MARK: - Mock Results

    private(set) var lastFlashMode: Bool = false
    private(set) var lastCaptureCompletion: ((Result<UIImage, Error>) -> Void)?
    private(set) var lastSetupCompletion: ((Result<AVCaptureVideoPreviewLayer, Error>) -> Void)?

    // MARK: - Initialization

    init() {
        setupDefaultMockValues()
    }

    private func setupDefaultMockValues() {
        mockPreviewLayer = AVCaptureVideoPreviewLayer()
        mockCapturedImage = TestHelpers.createTestImage()
        mockError = TestHelpers.createMockError(message: "Mock camera error")
    }

    // MARK: - Reset

    func reset() {
        setupCameraCallCount = 0
        startSessionCallCount = 0
        stopSessionCallCount = 0
        capturePhotoCallCount = 0
        switchCameraCallCount = 0
        setFlashModeCallCount = 0
        toggleFlashCallCount = 0

        shouldSimulateSetupFailure = false
        shouldSimulateCaptureFailure = false
        shouldSimulateSwitchFailure = false
        setupDelay = 0
        captureDelay = 0

        lastFlashMode = false
        lastCaptureCompletion = nil
        lastSetupCompletion = nil

        setupDefaultMockValues()
    }

    // MARK: - Mock Simulation Helpers

    func simulateSetupSuccess() {
        shouldSimulateSetupFailure = false
    }

    func simulateSetupFailure(error: Error? = nil) {
        shouldSimulateSetupFailure = true
        if let error = error {
            mockError = error
        }
    }

    func simulateCaptureSuccess(image: UIImage? = nil) {
        shouldSimulateCaptureFailure = false
        if let image = image {
            mockCapturedImage = image
        }
    }

    func simulateCaptureFailure(error: Error? = nil) {
        shouldSimulateCaptureFailure = true
        if let error = error {
            mockError = error
        }
    }

    func simulateSwitchSuccess() {
        shouldSimulateSwitchFailure = false
    }

    func simulateSwitchFailure(error: Error? = nil) {
        shouldSimulateSwitchFailure = true
        if let error = error {
            mockError = error
        }
    }
}

// MARK: - CameraManager Interface

extension MockCameraManager {

    func setupCamera(completion: @escaping (Result<AVCaptureVideoPreviewLayer, Error>) -> Void) {
        setupCameraCallCount += 1
        lastSetupCompletion = completion

        let executeCompletion = {
            if self.shouldSimulateSetupFailure {
                completion(.failure(self.mockError ?? CameraError.deviceNotFound))
            } else {
                completion(.success(self.mockPreviewLayer ?? AVCaptureVideoPreviewLayer()))
            }
        }

        if setupDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + setupDelay) {
                executeCompletion()
            }
        } else {
            executeCompletion()
        }
    }

    func startSession() {
        startSessionCallCount += 1
    }

    func stopSession() {
        stopSessionCallCount += 1
    }

    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        capturePhotoCallCount += 1
        lastCaptureCompletion = completion

        let executeCompletion = {
            if self.shouldSimulateCaptureFailure {
                completion(.failure(self.mockError ?? CameraError.imageProcessingFailed))
            } else {
                completion(.success(self.mockCapturedImage ?? TestHelpers.createTestImage()))
            }
        }

        if captureDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + captureDelay) {
                executeCompletion()
            }
        } else {
            executeCompletion()
        }
    }

    func switchCamera() {
        switchCameraCallCount += 1

        if shouldSimulateSwitchFailure {
            // In a real implementation, this might call a delegate method with error
            // For mock, we just record the attempt
        }
    }

    func setFlashMode(_ enabled: Bool) {
        setFlashModeCallCount += 1
        lastFlashMode = enabled
    }

    func toggleFlash() {
        toggleFlashCallCount += 1
        lastFlashMode.toggle()
    }
}

// MARK: - Test Assertions

extension MockCameraManager {

    func assertSetupCameraCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(setupCameraCallCount, times, "setupCamera should be called \(times) time(s)", file: file, line: line)
    }

    func assertStartSessionCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(startSessionCallCount, times, "startSession should be called \(times) time(s)", file: file, line: line)
    }

    func assertStopSessionCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(stopSessionCallCount, times, "stopSession should be called \(times) time(s)", file: file, line: line)
    }

    func assertCapturePhotoCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(capturePhotoCallCount, times, "capturePhoto should be called \(times) time(s)", file: file, line: line)
    }

    func assertSwitchCameraCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(switchCameraCallCount, times, "switchCamera should be called \(times) time(s)", file: file, line: line)
    }

    func assertSetFlashModeCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(setFlashModeCallCount, times, "setFlashMode should be called \(times) time(s)", file: file, line: line)
    }

    func assertToggleFlashCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(toggleFlashCallCount, times, "toggleFlash should be called \(times) time(s)", file: file, line: line)
    }

    func assertFlashMode(_ expectedMode: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lastFlashMode, expectedMode, "Flash mode should be \(expectedMode)", file: file, line: line)
    }

    func assertNoCalls(file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(setupCameraCallCount, 0, "No camera setup calls expected", file: file, line: line)
        XCTAssertEqual(startSessionCallCount, 0, "No start session calls expected", file: file, line: line)
        XCTAssertEqual(stopSessionCallCount, 0, "No stop session calls expected", file: file, line: line)
        XCTAssertEqual(capturePhotoCallCount, 0, "No capture photo calls expected", file: file, line: line)
        XCTAssertEqual(switchCameraCallCount, 0, "No switch camera calls expected", file: file, line: line)
        XCTAssertEqual(setFlashModeCallCount, 0, "No set flash mode calls expected", file: file, line: line)
        XCTAssertEqual(toggleFlashCallCount, 0, "No toggle flash calls expected", file: file, line: line)
    }
}

// MARK: - Advanced Mock Scenarios

extension MockCameraManager {

    func simulateRealWorldCameraSetup() {
        setupDelay = 0.1 // Simulate realistic setup time
        simulateSetupSuccess()
    }

    func simulateSlowCamera() {
        setupDelay = 0.5
        captureDelay = 0.3
    }

    func simulatePermissionDenied() {
        simulateSetupFailure(error: CameraError.permissionDenied)
    }

    func simulateDeviceNotFound() {
        simulateSetupFailure(error: CameraError.deviceNotFound)
    }

    func simulateImageProcessingFailure() {
        simulateCaptureFailure(error: CameraError.imageProcessingFailed)
    }

    func simulateMemoryPressure() {
        simulateCaptureFailure(error: NSError(domain: "MemoryDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Memory pressure"]))
    }

    func simulateMultipleQuickCaptures() {
        captureDelay = 0 // Instant captures for testing rapid succession
        simulateCaptureSuccess()
    }
}