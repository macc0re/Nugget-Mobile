import SwiftUI

@main
struct NuggetApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                ToolsView()
                    .tabItem {
                        Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                    }
            }
            .environmentObject(state)
            .tint(NuggetStyle.accent)
            .preferredColorScheme(.dark)
        }
    }
}
