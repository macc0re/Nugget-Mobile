import SwiftUI

@main
struct NuggetApp: App {
    var body: some Scene {
        WindowGroup {
            // Swap StubBackend() for your real TweakBackend implementation.
            NuggetRootView(backend: StubBackend())
        }
    }
}
