//
//  AppState.swift
//  Shared observable state across Home and Tools screens.
//

import SwiftUI

@MainActor
final class AppState: ObservableObject {
    let backend: TweakBackend

    @Published var toggles: [String: Bool] = [:]
    @Published var autoRebootAfterApply: Bool = true
    @Published var isApplying = false
    @Published var errorMessage: String?

    /// Whether the last extracted/loaded gestalt state is considered valid.
    /// Drives the checkmark vs. X badge in each tool page's nav bar.
    @Published var gestaltVerified = true

    init(backend: TweakBackend = StubBackend()) {
        self.backend = backend
    }

    func binding(for id: String, default defaultValue: Bool = false) -> Binding<Bool> {
        Binding(
            get: { self.toggles[id] ?? defaultValue },
            set: { newValue in
                self.toggles[id] = newValue
                Task {
                    do {
                        try await self.backend.setToggle(id, to: newValue)
                    } catch {
                        self.errorMessage = "Couldn't set \(id): \(error.localizedDescription)"
                    }
                }
            }
        )
    }

    func refresh() async {
        toggles = await backend.currentValues()
    }

    func applyTweaks() {
        isApplying = true
        Task {
            defer { isApplying = false }
            do {
                try await backend.applyAll()
            } catch {
                errorMessage = "Failed to apply tweaks: \(error.localizedDescription)"
            }
        }
    }

    func removeAllTweaks() {
        isApplying = true
        Task {
            defer { isApplying = false }
            do {
                try await backend.removeAll()
                toggles.removeAll()
            } catch {
                errorMessage = "Failed to remove tweaks: \(error.localizedDescription)"
            }
        }
    }
}
