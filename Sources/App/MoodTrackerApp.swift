import SwiftUI
import Core

@main
struct MoodTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(macOS 13.0, *) {
                MainView()
            }
        }
    }
} 