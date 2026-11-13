import SwiftUI

@main
struct NuggetApp: App {
    // Swap StubBackend() for your real TweakBackend implementation.
    @StateObject private var state = AppState(backend: StubBackend())

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }

                ToolsView()
                    .tabItem { Label("Tools", systemImage: "wrench.and.screwdriver") }
            }
            .environmentObject(state)
        }
    }
}
