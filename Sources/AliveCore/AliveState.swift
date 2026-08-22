import Foundation

public struct AliveState: Equatable, Sendable {
    public var manualModeEnabled: Bool
    public var autoDetectionEnabled: Bool
    public var keepDisplayAwake: Bool
    public var detectedProcesses: [AgentProcess]
    public var assertionError: String?

    public init(
        manualModeEnabled: Bool = false,
        autoDetectionEnabled: Bool = true,
        keepDisplayAwake: Bool = true,
        detectedProcesses: [AgentProcess] = [],
        assertionError: String? = nil
    ) {
        self.manualModeEnabled = manualModeEnabled
        self.autoDetectionEnabled = autoDetectionEnabled
        self.keepDisplayAwake = keepDisplayAwake
        self.detectedProcesses = detectedProcesses
        self.assertionError = assertionError
    }

    public var isKeepingAwake: Bool {
        manualModeEnabled || (autoDetectionEnabled && !detectedProcesses.isEmpty)
    }

    public var activeReason: String? {
        if manualModeEnabled { return "Manual session" }
        guard autoDetectionEnabled, !detectedProcesses.isEmpty else { return nil }

        let agents = Set(detectedProcesses.map(\.agent))
        if agents.count == 2 { return "Claude Code + Codex detected" }
        return "\(agents.first!.rawValue) detected"
    }
}
