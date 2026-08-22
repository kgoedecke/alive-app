import Foundation

public protocol AgentProcessDetecting {
    func runningAgents() -> [AgentProcess]
}

public struct AgentProcessDetector: AgentProcessDetecting {
    public init() {}

    public func runningAgents() -> [AgentProcess] {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-axo", "pid=,command="]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0,
                  let output = String(data: data, encoding: .utf8)
            else { return [] }

            return ProcessListParser.parse(output, excluding: ProcessInfo.processInfo.processIdentifier)
        } catch {
            return []
        }
    }
}
