import UIKit
import Foundation

class ErrorHandler {

    static let shared = ErrorHandler()

    private init() {}

    func handle(_ error: Error, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        let (title, message) = parseError(error)
        showAlert(title: title, message: message, in: viewController, completion: completion)
    }

    func handleCameraError(_ error: Error, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        if let cameraError = error as? CameraError {
            switch cameraError {
            case .permissionDenied:
                showPermissionAlert(
                    title: Constants.Permissions.Camera.title,
                    message: Constants.Permissions.Camera.message,
                    in: viewController,
                    completion: completion
                )
                return
            default:
                break
            }
        }

        handle(error, in: viewController, completion: completion)
    }

    func handleStorageError(_ error: Error, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        if let storageError = error as? StorageError {
            let (title, message) = parseStorageError(storageError)
            showAlert(title: title, message: message, in: viewController, completion: completion)
        } else {
            handle(error, in: viewController, completion: completion)
        }
    }

    private func parseError(_ error: Error) -> (title: String, message: String) {
        if let localizedError = error as? LocalizedError {
            return (
                title: localizedError.errorDescription ?? Constants.Errors.genericTitle,
                message: localizedError.failureReason ?? Constants.Errors.genericMessage
            )
        }

        if let cameraError = error as? CameraError {
            return parseCameraError(cameraError)
        }

        if let storageError = error as? StorageError {
            return parseStorageError(storageError)
        }

        return (
            title: Constants.Errors.genericTitle,
            message: error.localizedDescription
        )
    }

    private func parseCameraError(_ error: CameraError) -> (title: String, message: String) {
        switch error {
        case .permissionDenied:
            return ("Camera Access Denied", "Please enable camera access in Settings to take photos.")
        case .deviceNotFound:
            return ("Camera Not Available", "No camera device was found on this device.")
        case .inputError:
            return ("Camera Setup Error", "Failed to configure camera input.")
        case .outputError:
            return ("Camera Setup Error", "Failed to configure camera output.")
        case .imageProcessingFailed:
            return ("Photo Processing Error", "Failed to process the captured photo.")
        case .sessionNotRunning:
            return ("Camera Not Ready", "Please wait for the camera to initialize before taking photos.")
        case .noActiveConnection:
            return ("Camera Connection Error", "No active camera connection available. Please restart the camera.")
        }
    }

    private func parseStorageError(_ error: StorageError) -> (title: String, message: String) {
        switch error {
        case .compressionFailed:
            return (Constants.Errors.storageTitle, "Failed to compress photo for storage.")
        case .fileNotFound:
            return (Constants.Errors.storageTitle, "Photo file not found.")
        case .writeFailed:
            return (Constants.Errors.storageTitle, "Failed to save photo to storage.")
        case .readFailed:
            return (Constants.Errors.storageTitle, "Failed to read photo from storage.")
        case .invalidData:
            return (Constants.Errors.storageTitle, "Invalid photo data.")
        }
    }

    private func showAlert(title: String, message: String, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            viewController.present(alert, animated: true)
        }
    }

    private func showPermissionAlert(title: String, message: String, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Constants.Permissions.Camera.cancelButtonTitle, style: .cancel) { _ in
                completion?()
            })

            alert.addAction(UIAlertAction(title: Constants.Permissions.Camera.settingsButtonTitle, style: .default) { _ in
                self.openSettings()
                completion?()
            })

            viewController.present(alert, animated: true)
        }
    }

    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }

        UIApplication.shared.open(settingsUrl)
    }

    func logError(_ error: Error, context: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let errorDescription = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription

        print("🔴 ERROR [\(fileName):\(line)] \(function)")
        print("   Context: \(context)")
        print("   Error: \(errorDescription)")

        #if DEBUG
        if let nsError = error as NSError? {
            print("   Domain: \(nsError.domain)")
            print("   Code: \(nsError.code)")
            if !nsError.userInfo.isEmpty {
                print("   UserInfo: \(nsError.userInfo)")
            }
        }
        #endif
    }

    func showSuccessMessage(_ message: String, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        showAlert(title: "Success", message: message, in: viewController, completion: completion)
    }

    func showWarningMessage(_ message: String, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        showAlert(title: "Warning", message: message, in: viewController, completion: completion)
    }

    func showConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        in viewController: UIViewController,
        confirmAction: @escaping () -> Void,
        cancelAction: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                cancelAction?()
            })

            alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in
                confirmAction()
            })

            viewController.present(alert, animated: true)
        }
    }
}