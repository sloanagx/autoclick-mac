import SwiftUI
import AppKit
import ApplicationServices
import Combine

@main
struct AGXAutoClickerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    var body: some Scene {
        WindowGroup("AGX Auto Clicker") {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        true
    }
}

@MainActor
final class Clicker: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var status = "Ready"
    @Published private(set) var clickCount = 0

    private var clickingTask: Task<Void, Never>?
    private var globalMonitor: Any?
    private var localMonitor: Any?

    func requestPermission() {
        let options = [
            "AXTrustedCheckOptionPrompt": true
        ] as CFDictionary

        let granted = AXIsProcessTrustedWithOptions(options)

        status = granted
            ? "Accessibility access is enabled."
            : "Enable Accessibility access, then restart the app."
    }

    func start(interval: Double) {
        guard !isRunning else { return }

        guard interval.isFinite, interval >= 0.05, interval <= 3600 else {
            status = "Enter an interval from 0.05 to 3600 seconds."
            return
        }

        guard AXIsProcessTrusted() else {
            requestPermission()
            return
        }

        installStopShortcut()

        guard globalMonitor != nil, localMonitor != nil else {
            status = "Could not install the stop shortcut."
            removeStopShortcut()
            return
        }

        isRunning = true
        clickCount = 0

        clickingTask = Task { @MainActor [weak self] in
            do {
                for seconds in stride(from: 3, through: 1, by: -1) {
                    self?.status = "Starting in \(seconds)… Move your cursor."
                    try await Task.sleep(for: .seconds(1))
                }

                while !Task.isCancelled {
                    guard let self else { return }

                    guard AXIsProcessTrusted() else {
                        self.stop()
                        self.status = "Accessibility access was removed."
                        return
                    }

                    guard self.performClick() else {
                        self.stop()
                        self.status = "Could not create a mouse click."
                        return
                    }

                    self.clickCount += 1
                    self.status = "Clicking…"
                    try await Task.sleep(for: .seconds(interval))
                }
            } catch {
                // Stop cancels the waiting task.
            }
        }
    }

    func stop() {
        clickingTask?.cancel()
        clickingTask = nil
        isRunning = false
        status = "Stopped"
        removeStopShortcut()
    }

    private func performClick() -> Bool {
        guard
            let position = CGEvent(source: nil)?.location,
            let mouseDown = CGEvent(
                mouseEventSource: nil,
                mouseType: .leftMouseDown,
                mouseCursorPosition: position,
                mouseButton: .left
            ),
            let mouseUp = CGEvent(
                mouseEventSource: nil,
                mouseType: .leftMouseUp,
                mouseCursorPosition: position,
                mouseButton: .left
            )
        else {
            return false
        }

        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)
        return true
    }

    private func installStopShortcut() {
        removeStopShortcut()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: .keyDown
        ) { [weak self] event in
            let modifiers = event.modifierFlags
                .intersection(.deviceIndependentFlagsMask)

            if event.charactersIgnoringModifiers?.lowercased() == "s",
               modifiers.contains([.command, .shift]) {
                Task { @MainActor [weak self] in
                    self?.stop()
                }
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: .keyDown
        ) { [weak self] event in
            let modifiers = event.modifierFlags
                .intersection(.deviceIndependentFlagsMask)

            if event.charactersIgnoringModifiers?.lowercased() == "s",
               modifiers.contains([.command, .shift]) {
                Task { @MainActor [weak self] in
                    self?.stop()
                }
                return nil
            }

            return event
        }
    }

    private func removeStopShortcut() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }

        globalMonitor = nil
        localMonitor = nil
    }
}

struct ContentView: View {
    @StateObject private var clicker = Clicker()
    @State private var interval = 1.0

    var body: some View {
        VStack(spacing: 20) {
            Text("AGX Auto Clicker")
                .font(.largeTitle.bold())

            Text("Left-click at your cursor’s position.")
                .foregroundStyle(.secondary)

            HStack {
                Text("Interval (seconds):")

                TextField("Seconds", value: $interval, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 90)
                    .disabled(clicker.isRunning)
            }

            HStack(spacing: 16) {
                Button("Start") {
                    clicker.start(interval: interval)
                }
                .buttonStyle(.borderedProminent)
                .disabled(clicker.isRunning)

                Button("Stop") {
                    clicker.stop()
                }
                .disabled(!clicker.isRunning)
            }

            Text(clicker.status)
                .font(.callout)
                .multilineTextAlignment(.center)

            Text("Clicks sent: \(clicker.clickCount)")
                .monospacedDigit()

            Text("Press ⌘⇧S to stop from any app.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Enable Accessibility Access") {
                clicker.requestPermission()
            }
            .disabled(clicker.isRunning)

            Text("Developed by AGX")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(width: 440, height: 400)
        .onDisappear {
            clicker.stop()
        }
    }
}        
