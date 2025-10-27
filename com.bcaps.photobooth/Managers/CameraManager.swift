import AVFoundation
import UIKit
import CoreMedia

class CameraManager: NSObject {

    static let shared = CameraManager()

    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var photoCaptureCompletionHandler: ((Result<UIImage, Error>) -> Void)?
    private var isFlashEnabled = false

    override init() {
        super.init()
    }

    func setupCamera(completion: @escaping (Result<AVCaptureVideoPreviewLayer, Error>) -> Void) {
        checkCameraPermission { [weak self] granted in
            if granted {
                self?.configureCameraSession(completion: completion)
            } else {
                completion(.failure(CameraError.permissionDenied))
            }
        }
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func configureCameraSession(completion: @escaping (Result<AVCaptureVideoPreviewLayer, Error>) -> Void) {
        captureSession.beginConfiguration()

        captureSession.sessionPreset = .photo

        do {
            // Try front camera first, then back camera, then any available camera
            var videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            if videoDevice == nil {
                videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            }
            if videoDevice == nil {
                videoDevice = AVCaptureDevice.default(for: .video)
            }

            guard let device = videoDevice else {
                throw CameraError.deviceNotFound
            }

            let videoDeviceInput = try AVCaptureDeviceInput(device: device)

            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                throw CameraError.inputError
            }

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                if #available(iOS 16.0, *) {
                    photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
                } else {
                    photoOutput.isHighResolutionCaptureEnabled = true
                }
            } else {
                throw CameraError.outputError
            }

            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer = previewLayer

            captureSession.commitConfiguration()

            completion(.success(previewLayer))

        } catch {
            captureSession.commitConfiguration()
            completion(.failure(error))
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard captureSession.isRunning else {
            completion(.failure(CameraError.sessionNotRunning))
            return
        }

        guard let connection = photoOutput.connection(with: .video),
              connection.isEnabled,
              connection.isActive else {
            completion(.failure(CameraError.noActiveConnection))
            return
        }

        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])

        if isFlashEnabled && videoDeviceInput?.device.hasFlash == true {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }

        photoCaptureCompletionHandler = completion
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func switchCamera() {
        guard let currentVideoDevice = videoDeviceInput?.device else { return }

        let currentPosition = currentVideoDevice.position
        let preferredPosition: AVCaptureDevice.Position = currentPosition == .front ? .back : .front

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: preferredPosition) else {
            return
        }

        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            captureSession.beginConfiguration()

            if let currentInput = self.videoDeviceInput {
                captureSession.removeInput(currentInput)
            }

            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                // Restore previous input if available
                if let previousInput = self.videoDeviceInput {
                    captureSession.addInput(previousInput)
                }
            }

            captureSession.commitConfiguration()

        } catch {
            print("Error switching camera: \(error)")
        }
    }

    func setFlashMode(_ enabled: Bool) {
        isFlashEnabled = enabled
    }

    func toggleFlash() {
        isFlashEnabled.toggle()
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            photoCaptureCompletionHandler = nil
        }

        if let error = error {
            photoCaptureCompletionHandler?(.failure(error))
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletionHandler?(.failure(CameraError.imageProcessingFailed))
            return
        }

        let orientedImage = image.fixedOrientation()
        photoCaptureCompletionHandler?(.success(orientedImage))
    }
}

enum CameraError: Error, LocalizedError {
    case permissionDenied
    case deviceNotFound
    case inputError
    case outputError
    case imageProcessingFailed
    case sessionNotRunning
    case noActiveConnection

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission denied"
        case .deviceNotFound:
            return "Camera device not found"
        case .inputError:
            return "Failed to add camera input"
        case .outputError:
            return "Failed to add photo output"
        case .imageProcessingFailed:
            return "Failed to process captured image"
        case .sessionNotRunning:
            return "Camera session is not running"
        case .noActiveConnection:
            return "No active video connection available"
        }
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}