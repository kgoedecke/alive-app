import Foundation

public enum CodingAgent: String, CaseIterable, Sendable {
    case claudeCode = "Claude Code"
    case codex = "Codex"

    public var shortName: String {
        switch self {
        case .claudeCode: "Claude"
        case .codex: "Codex"
        }
    }
}

public struct AgentProcess: Equatable, Sendable, Identifiable {
    public let pid: Int32
    public let agent: CodingAgent
    public let command: String

    public var id: Int32 { pid }

    public init(pid: Int32, agent: CodingAgent, command: String) {
        self.pid = pid
        self.agent = agent
        self.command = command
    }
}
