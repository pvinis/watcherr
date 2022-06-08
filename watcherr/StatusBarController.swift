import AppKit
import SwiftUI


class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem

    init() {
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: nil)
            statusBarButton.image?.isTemplate = true
        }
    }
}
