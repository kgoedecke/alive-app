import AliveCore
import AppKit

@MainActor
final class MenuController: NSObject {
    private let statusItem: NSStatusItem
    private let service: AliveService
    private let launchAtLogin = LaunchAtLoginController()
    private let menu = NSMenu()

    private let statusMenuItem = NSMenuItem(title: "Alive is ready", action: nil, keyEquivalent: "")
    private let reasonMenuItem = NSMenuItem(title: "Waiting for Claude Code or Codex", action: nil, keyEquivalent: "")
    private let manualMenuItem = NSMenuItem(title: "Keep Awake Now", action: #selector(toggleManual), keyEquivalent: "k")
    private let autoMenuItem = NSMenuItem(title: "Auto-detect Claude Code & Codex", action: #selector(toggleAutoDetection), keyEquivalent: "a")
    private let displayMenuItem = NSMenuItem(title: "Keep Display Awake", action: #selector(toggleDisplayAwake), keyEquivalent: "d")
    private let sessionsMenuItem = NSMenuItem(title: "No agent sessions detected", action: nil, keyEquivalent: "")
    private let launchMenuItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")

    init(service: AliveService) {
        self.service = service
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        configureStatusItem()
        configureMenu()
        service.onStateChange = { [weak self] state in self?.render(state) }
        service.start()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "bolt.heart", accessibilityDescription: "Alive")
        button.image?.isTemplate = true
        button.toolTip = "Alive — waiting for a coding agent"
        statusItem.menu = menu
    }

    private func configureMenu() {
        statusMenuItem.isEnabled = false
        statusMenuItem.attributedTitle = headline("Alive is ready")
        reasonMenuItem.isEnabled = false
        sessionsMenuItem.isEnabled = false

        [manualMenuItem, autoMenuItem, displayMenuItem, launchMenuItem].forEach { $0.target = self }

        menu.addItem(statusMenuItem)
        menu.addItem(reasonMenuItem)
        menu.addItem(.separator())
        menu.addItem(manualMenuItem)
        menu.addItem(autoMenuItem)
        menu.addItem(displayMenuItem)
        menu.addItem(.separator())
        menu.addItem(sessionsMenuItem)
        menu.addItem(.separator())
        menu.addItem(launchMenuItem)
        menu.addItem(linkItem(title: "Alive Website", url: "https://alive-site-production.up.railway.app"))
        menu.addItem(linkItem(title: "View Source on GitHub", url: "https://github.com/kgoedecke/alive-app"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "About Alive", action: #selector(showAbout), keyEquivalent: ""))
        menu.items.last?.target = self
        menu.addItem(NSMenuItem(title: "Quit Alive", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    private func render(_ state: AliveState) {
        let active = state.isKeepingAwake
        let iconName = active ? "bolt.heart.fill" : "bolt.heart"
        statusItem.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Alive")
        statusItem.button?.image?.isTemplate = true
        statusItem.button?.toolTip = active ? "Alive — your Mac is staying awake" : "Alive — waiting for a coding agent"

        statusMenuItem.attributedTitle = headline(active ? "Your Mac is staying awake" : "Alive is standing by")
        reasonMenuItem.title = state.assertionError ?? state.activeReason ?? "Waiting for Claude Code or Codex"
        manualMenuItem.state = state.manualModeEnabled ? .on : .off
        autoMenuItem.state = state.autoDetectionEnabled ? .on : .off
        displayMenuItem.state = state.keepDisplayAwake ? .on : .off
        launchMenuItem.state = launchAtLogin.isEnabled ? .on : .off

        let count = state.detectedProcesses.count
        sessionsMenuItem.title = count == 0
            ? "No agent sessions detected"
            : "\(count) agent session\(count == 1 ? "" : "s") detected"
        sessionsMenuItem.isEnabled = count > 0
        sessionsMenuItem.submenu = sessionsMenu(for: state.detectedProcesses)
    }

    private func headline(_ title: String) -> NSAttributedString {
        NSAttributedString(string: title, attributes: [.font: NSFont.boldSystemFont(ofSize: 13)])
    }

    private func linkItem(title: String, url: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(openLink(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = url
        return item
    }

    private func sessionsMenu(for processes: [AgentProcess]) -> NSMenu? {
        guard !processes.isEmpty else { return nil }
        let submenu = NSMenu(title: "Detected Sessions")
        for process in processes.sorted(by: { $0.agent.rawValue < $1.agent.rawValue }) {
            let item = NSMenuItem(
                title: "\(process.agent.rawValue) — PID \(process.pid)",
                action: nil,
                keyEquivalent: ""
            )
            item.image = NSImage(
                systemSymbolName: process.agent == .claudeCode ? "sparkles" : "terminal",
                accessibilityDescription: process.agent.rawValue
            )
            submenu.addItem(item)
        }
        return submenu
    }

    @objc private func toggleManual() { service.toggleManualMode() }
    @objc private func toggleAutoDetection() { service.toggleAutoDetection() }
    @objc private func toggleDisplayAwake() { service.toggleDisplayAwake() }

    @objc private func toggleLaunchAtLogin() {
        if let error = launchAtLogin.setEnabled(!launchAtLogin.isEnabled) {
            let alert = NSAlert()
            alert.messageText = "Couldn’t update Launch at Login"
            alert.informativeText = error
            alert.alertStyle = .warning
            alert.runModal()
        }
        launchMenuItem.state = launchAtLogin.isEnabled ? .on : .off
    }

    @objc private func openLink(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String, let url = URL(string: value) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Alive",
            .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev",
            .credits: NSAttributedString(string: "An open-source utility for uninterrupted coding-agent sessions.")
        ])
        NSApp.activate(ignoringOtherApps: true)
    }
}
