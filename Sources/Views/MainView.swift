import SwiftUI
import Core

@available(macOS 13.0, *)
public struct MainView: View {
    public init() {}
    
    public var body: some View {
        TabView {
            MoodListView()
                .tabItem {
                    Label("Настроения", systemImage: "list.bullet")
                }
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
} 