import XCTest
@testable import AliveCore

final class AliveStateTests: XCTestCase {
    func testManualModeKeepsAwakeWithoutDetectedAgents() {
        let state = AliveState(manualModeEnabled: true, autoDetectionEnabled: false)

        XCTAssertTrue(state.isKeepingAwake)
        XCTAssertEqual(state.activeReason, "Manual session")
    }

    func testAutoModeKeepsAwakeForDetectedAgent() {
        let process = AgentProcess(pid: 42, agent: .claudeCode, command: "claude")
        let state = AliveState(detectedProcesses: [process])

        XCTAssertTrue(state.isKeepingAwake)
        XCTAssertEqual(state.activeReason, "Claude Code detected")
    }

    func testDisabledAutoModeIgnoresDetectedAgent() {
        let process = AgentProcess(pid: 42, agent: .codex, command: "codex")
        let state = AliveState(autoDetectionEnabled: false, detectedProcesses: [process])

        XCTAssertFalse(state.isKeepingAwake)
        XCTAssertNil(state.activeReason)
    }

    func testNamesBothAgentsWhenBothAreRunning() {
        let state = AliveState(detectedProcesses: [
            AgentProcess(pid: 1, agent: .claudeCode, command: "claude"),
            AgentProcess(pid: 2, agent: .codex, command: "codex")
        ])

        XCTAssertEqual(state.activeReason, "Claude Code + Codex detected")
    }
}
