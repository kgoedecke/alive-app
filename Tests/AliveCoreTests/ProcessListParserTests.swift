import XCTest
@testable import AliveCore

final class ProcessListParserTests: XCTestCase {
    func testFindsClaudeAndCodexCommands() {
        let output = """
          101 /Users/test/.local/bin/claude --dangerously-skip-permissions
          202 /opt/homebrew/bin/codex exec --full-auto
          303 /System/Library/CoreServices/Finder.app/Contents/MacOS/Finder
        """

        let processes = ProcessListParser.parse(output)

        XCTAssertEqual(processes.map(\.pid), [101, 202])
        XCTAssertEqual(processes.map(\.agent), [.claudeCode, .codex])
    }

    func testMatchesVersionedCodexBinary() {
        let line = "404 /Users/test/.cache/codex-aarch64-apple-darwin --session 123"

        XCTAssertEqual(ProcessListParser.parseLine(line)?.agent, .codex)
    }

    func testDoesNotMatchIncidentalWords() {
        let output = """
          501 /usr/bin/vim /tmp/claude-notes.md
          502 /Applications/Codexical.app/Contents/MacOS/Codexical
          503 /bin/zsh -c echo codex
        """

        XCTAssertTrue(ProcessListParser.parse(output).isEmpty)
    }

    func testExcludesAliveProcess() {
        let line = "700 /opt/homebrew/bin/codex exec"

        XCTAssertNil(ProcessListParser.parseLine(line, excluding: 700))
    }

    func testIgnoresLongLivedCodexServices() {
        XCTAssertNil(ProcessListParser.parseLine("801 /Applications/ChatGPT.app/Contents/Resources/codex app-server"))
        XCTAssertNil(ProcessListParser.parseLine("802 /opt/homebrew/bin/codex mcp-server"))
    }
}
