import Foundation
import IOKit.pwr_mgt

@MainActor
final class WakeAssertion {
    private var systemAssertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0

    var isActive: Bool { systemAssertionID != 0 }

    @discardableResult
    func activate(preventDisplaySleep: Bool) -> String? {
        release()

        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Alive is watching an active coding-agent session" as CFString,
            &systemAssertionID
        )

        guard systemResult == kIOReturnSuccess else {
            systemAssertionID = 0
            return "Could not create the system wake assertion (\(systemResult))."
        }

        guard preventDisplaySleep else { return nil }

        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Alive is keeping the display available for an active coding-agent session" as CFString,
            &displayAssertionID
        )

        guard displayResult == kIOReturnSuccess else {
            displayAssertionID = 0
            return "System sleep is blocked, but the display assertion failed (\(displayResult))."
        }

        return nil
    }

    func release() {
        if systemAssertionID != 0 {
            IOPMAssertionRelease(systemAssertionID)
            systemAssertionID = 0
        }

        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }
    }

    deinit {
        if systemAssertionID != 0 { IOPMAssertionRelease(systemAssertionID) }
        if displayAssertionID != 0 { IOPMAssertionRelease(displayAssertionID) }
    }
}
