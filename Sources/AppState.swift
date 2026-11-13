import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var toggles: [String: Bool] = [:]
    @Published var isApplying = false
    @Published var errorMessage: String?
    @Published var noticeMessage: String?
    @Published var gestaltVerified = false

    func binding(for id: String, default defaultValue: Bool = false) -> Binding<Bool> {
        Binding(
            get: { self.toggles[id] ?? defaultValue },
            set: { self.toggles[id] = $0 }
        )
    }

    func refresh() async {
        // UI phase: values remain local until the tweak engine is integrated.
    }

    func applyTweaks() {
        noticeMessage = "The tweak engine is not connected yet. Your selections have not been applied."
    }

    func removeAllTweaks() {
        toggles.removeAll()
        noticeMessage = "Local selections were cleared. System tweaks have not been changed."
    }
}
