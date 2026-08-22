import AliveCore
import Foundation

@MainActor
final class AliveService {
    private let detector: AgentProcessDetecting
    private let settings: SettingsStore
    private let wakeAssertion: WakeAssertion
    private var timer: Timer?

    private(set) var state: AliveState {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((AliveState) -> Void)?

    init(detector: AgentProcessDetecting = AgentProcessDetector()) {
        let settings = SettingsStore()
        let wakeAssertion = WakeAssertion()
        self.detector = detector
        self.settings = settings
        self.wakeAssertion = wakeAssertion
        self.state = AliveState(
            autoDetectionEnabled: settings.autoDetectionEnabled,
            keepDisplayAwake: settings.keepDisplayAwake
        )
    }

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
    }

    func toggleManualMode() {
        state.manualModeEnabled.toggle()
        synchronizeAssertion()
    }

    func toggleAutoDetection() {
        state.autoDetectionEnabled.toggle()
        settings.autoDetectionEnabled = state.autoDetectionEnabled
        refresh()
    }

    func toggleDisplayAwake() {
        state.keepDisplayAwake.toggle()
        settings.keepDisplayAwake = state.keepDisplayAwake
        synchronizeAssertion(forceRestart: true)
    }

    func refresh() {
        state.detectedProcesses = detector.runningAgents()
        synchronizeAssertion()
    }

    private func synchronizeAssertion(forceRestart: Bool = false) {
        if state.isKeepingAwake {
            if !wakeAssertion.isActive || forceRestart {
                state.assertionError = wakeAssertion.activate(preventDisplaySleep: state.keepDisplayAwake)
            }
        } else {
            wakeAssertion.release()
            state.assertionError = nil
        }
    }
}
