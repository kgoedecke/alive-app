import Foundation

@MainActor
final class SettingsStore {
    private enum Key {
        static let autoDetectionEnabled = "autoDetectionEnabled"
        static let keepDisplayAwake = "keepDisplayAwake"
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if !defaults.bool(forKey: Key.hasLaunchedBefore) {
            defaults.set(true, forKey: Key.autoDetectionEnabled)
            defaults.set(true, forKey: Key.keepDisplayAwake)
            defaults.set(true, forKey: Key.hasLaunchedBefore)
        }
    }

    var autoDetectionEnabled: Bool {
        get { defaults.bool(forKey: Key.autoDetectionEnabled) }
        set { defaults.set(newValue, forKey: Key.autoDetectionEnabled) }
    }

    var keepDisplayAwake: Bool {
        get { defaults.bool(forKey: Key.keepDisplayAwake) }
        set { defaults.set(newValue, forKey: Key.keepDisplayAwake) }
    }
}
