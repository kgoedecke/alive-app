import Foundation

public enum ProcessListParser {
    private static let commandPattern = try! NSRegularExpression(
        pattern: #"(?:^|/)(claude|codex)(?:-(?:aarch64|x86_64|universal)[A-Za-z0-9_-]*)?$"#,
        options: [.caseInsensitive]
    )

    public static func parse(_ output: String, excluding excludedPID: Int32? = nil) -> [AgentProcess] {
        output
            .split(whereSeparator: \.isNewline)
            .compactMap { parseLine(String($0), excluding: excludedPID) }
    }

    public static func parseLine(_ line: String, excluding excludedPID: Int32? = nil) -> AgentProcess? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let divider = trimmed.firstIndex(where: \.isWhitespace) else { return nil }

        let pidText = trimmed[..<divider]
        let command = trimmed[divider...].trimmingCharacters(in: .whitespaces)
        let executable = command.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? ""
        guard let pid = Int32(pidText), pid != excludedPID, !executable.isEmpty else { return nil }

        let range = NSRange(executable.startIndex..<executable.endIndex, in: executable)
        guard let match = commandPattern.firstMatch(in: executable, range: range),
              let agentRange = Range(match.range(at: 1), in: executable)
        else { return nil }

        let matchedAgent = executable[agentRange].lowercased()
        let agent: CodingAgent = matchedAgent == "claude" ? .claudeCode : .codex
        if agent == .codex, isBackgroundCodexService(command) { return nil }
        return AgentProcess(pid: pid, agent: agent, command: command)
    }

    private static func isBackgroundCodexService(_ command: String) -> Bool {
        let arguments = command.split(whereSeparator: \.isWhitespace).dropFirst().map { $0.lowercased() }
        return arguments.contains("app-server") || arguments.contains("mcp-server")
    }
}
