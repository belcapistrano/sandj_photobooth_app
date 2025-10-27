import Foundation

class SettingsStorage {
    static let shared = SettingsStorage()

    private let defaults = UserDefaults.standard

    private init() {}

    enum Key: String {
        case photoQuality
        case soundEnabled
        case countdownDuration
        case defaultFilter
        case hasSeenOnboarding
        case flashEnabled
        case gridEnabled
        case timerEnabled
    }

    func set<T>(_ value: T, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    func get<T>(for key: Key) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }

    func getBool(for key: Key, default defaultValue: Bool = false) -> Bool {
        if defaults.object(forKey: key.rawValue) == nil {
            return defaultValue
        }
        return defaults.bool(forKey: key.rawValue)
    }

    func getInt(for key: Key, default defaultValue: Int = 0) -> Int {
        if defaults.object(forKey: key.rawValue) == nil {
            return defaultValue
        }
        return defaults.integer(forKey: key.rawValue)
    }

    func getString(for key: Key, default defaultValue: String = "") -> String {
        return defaults.string(forKey: key.rawValue) ?? defaultValue
    }

    func remove(for key: Key) {
        defaults.removeObject(forKey: key.rawValue)
    }

    func resetToDefaults() {
        Key.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
    }
}

extension SettingsStorage.Key: CaseIterable {}