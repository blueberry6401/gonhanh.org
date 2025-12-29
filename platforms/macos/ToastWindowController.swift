//
//  ToastWindowController.swift
//  GoNhanh
//
//  Window controller for toast notifications
//

import Cocoa
import SwiftUI

class ToastWindowController {

    static let shared = ToastWindowController()

    private var window: NSWindow?
    private var hideWorkItem: DispatchWorkItem?

    private init() {}

    // MARK: - Public Methods

    func showToast(isVietnamese: Bool) {
        guard AppState.shared.toastEnabled else { return }
        DispatchQueue.main.async { [weak self] in
            self?.displayToast(isVietnamese: isVietnamese)
        }
    }

    // MARK: - Private Methods

    private func displayToast(isVietnamese: Bool) {
        // Cancel any pending hide operation
        hideWorkItem?.cancel()
        hideWorkItem = nil

        // Hide and remove old window immediately
        if let oldWindow = window {
            oldWindow.orderOut(nil)
            self.window = nil
        }

        // Create new window
        let toastWindow = createWindow(isVietnamese: isVietnamese)
        self.window = toastWindow

        // Position at center of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowSize = toastWindow.frame.size
            let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2 + 50
            toastWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }

        // Show with fade in
        toastWindow.alphaValue = 0
        toastWindow.orderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            toastWindow.animator().alphaValue = 1
        }

        // Schedule hide after 1 second
        let workItem = DispatchWorkItem { [weak self] in
            self?.hideToast()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }

    private func createWindow(isVietnamese: Bool) -> NSWindow {
        // Create borderless, floating window first with a large initial size
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: NSSize(width: 500, height: 200)),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Create SwiftUI view
        let toastView: AnyView
        if #available(macOS 13.0, *) {
            toastView = AnyView(ToastView(isVietnamese: isVietnamese))
        } else {
            toastView = AnyView(ToastViewLegacy(isVietnamese: isVietnamese))
        }

        // Wrap in hosting controller
        let hostingController = NSHostingController(rootView: toastView)

        // Set the content view controller
        window.contentViewController = hostingController

        // Make the hosting view's background transparent
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        // Force layout and get the fitting size
        hostingController.view.layoutSubtreeIfNeeded()
        let fittingSize = hostingController.view.fittingSize

        // Resize window to fit content
        window.setContentSize(fittingSize)

        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = .screenSaver
        window.ignoresMouseEvents = true
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        return window
    }

    private func hideToast() {
        guard let window = window else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.window?.orderOut(nil)
            self?.window = nil
        }
    }
}
