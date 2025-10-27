import Foundation
import UIKit

struct Constants {

    struct App {
        static let name = "PhotoBooth"
        static let version = "1.0"
        static let buildNumber = "1"
    }

    struct Camera {
        static let defaultQuality: Float = 0.8
        static let maxPhotosPerSession = 10
        static let countdownDuration = 3
        static let flashAutoTimeout: TimeInterval = 0.1
    }

    struct Storage {
        static let photoCompressionQuality: CGFloat = 0.8
        static let maxStorageSize: Int = 100 * 1024 * 1024 // 100MB
        static let sessionTimeoutHours: TimeInterval = 24
    }

    struct UI {
        struct Animation {
            static let defaultDuration: TimeInterval = 0.3
            static let springDamping: CGFloat = 0.8
            static let springVelocity: CGFloat = 0.5
        }

        struct Layout {
            static let defaultSpacing: CGFloat = 16
            static let defaultCornerRadius: CGFloat = 8
            static let buttonHeight: CGFloat = 50
            static let captureButtonSize: CGFloat = 80
        }

        struct Colors {
            static let primary = UIColor.systemBlue
            static let secondary = UIColor.systemGray
            static let accent = UIColor.systemPurple
            static let success = UIColor.systemGreen
            static let warning = UIColor.systemOrange
            static let danger = UIColor.systemRed
        }
    }

    struct Settings {
        struct Keys {
            static let hasCompletedOnboarding = "hasCompletedOnboarding"
            static let defaultPhotoQuality = "defaultPhotoQuality"
            static let soundEnabled = "soundEnabled"
            static let countdownEnabled = "countdownEnabled"
            static let gridEnabled = "gridEnabled"
            static let flashEnabled = "flashEnabled"
            static let defaultFilter = "defaultFilter"
            static let autoSaveToPhotos = "autoSaveToPhotos"
        }

        struct Defaults {
            static let photoQuality: Float = 0.8
            static let soundEnabled = true
            static let countdownEnabled = true
            static let gridEnabled = false
            static let flashEnabled = false
            static let autoSaveToPhotos = false
        }
    }

    struct Notifications {
        static let sessionCompleted = Notification.Name("SessionCompleted")
        static let photosCaptured = Notification.Name("PhotosCaptured")
        static let settingsChanged = Notification.Name("SettingsChanged")
        static let storageWarning = Notification.Name("StorageWarning")
    }

    struct UserDefaults {
        static let suiteName = "group.com.bcaps.photobooth"
    }

    struct Files {
        static let sessionsFileName = "sessions.json"
        static let settingsFileName = "settings.plist"
        static let photoFileExtension = "jpg"
    }

    struct Permissions {
        struct Camera {
            static let title = "Camera Access Required"
            static let message = "PhotoBooth needs access to your camera to take photos. Please enable camera access in Settings."
            static let settingsButtonTitle = "Settings"
            static let cancelButtonTitle = "Cancel"
        }

        struct PhotoLibrary {
            static let title = "Photo Library Access"
            static let message = "PhotoBooth needs access to your photo library to save photos. Please enable photo library access in Settings."
            static let settingsButtonTitle = "Settings"
            static let cancelButtonTitle = "Cancel"
        }
    }

    struct Errors {
        static let genericTitle = "Error"
        static let genericMessage = "Something went wrong. Please try again."
        static let networkTitle = "Connection Error"
        static let networkMessage = "Please check your internet connection and try again."
        static let storageTitle = "Storage Error"
        static let storageMessage = "Unable to save photo. Please check available storage space."
    }
}