//
//  NuggetUIShell.swift
//  UI-only shell for a Nugget-style on-device customization app.
//
//  This file deliberately contains NO backend / file-write / exploit logic.
//  Every tweak action routes through `TweakBackend`, a protocol you should
//  implement separately with whatever write mechanism you end up using.
//  Swap in a real conforming type at the call site in `NuggetApp`.
//

import SwiftUI

// MARK: - Backend boundary

/// Abstraction over "however a tweak actually gets applied."
/// Intentionally a stub here — wire up your own implementation elsewhere.
protocol TweakBackend {
    func isApplied(_ tweak: Tweak) async -> Bool
    func apply(_ tweak: Tweak, enabled: Bool) async throws
}

/// No-op backend so the UI is runnable/previewable on its own.
struct StubBackend: TweakBackend {
    func isApplied(_ tweak: Tweak) async -> Bool { false }
    func apply(_ tweak: Tweak, enabled: Bool) async throws {
        print("TODO: apply \(tweak.name) -> \(enabled)")
    }
}

// MARK: - Model

struct Tweak: Identifiable, Hashable {
    enum Category: String, CaseIterable {
        case display = "Display"
        case statusBar = "Status Bar"
        case system = "System"
        case misc = "Misc"
    }

    let id = UUID()
    let name: String
    let detail: String
    let category: Category
    let minVersion: String
    let systemImage: String
}

let knownTweaks: [Tweak] = [
    Tweak(name: "Dynamic Island", detail: "Enable Dynamic Island on unsupported devices", category: .display, minVersion: "17.0", systemImage: "circle.grid.cross"),
    Tweak(name: "Always-On Display", detail: "Enable AOD on any device", category: .display, minVersion: "17.0", systemImage: "moon.zzz"),
    Tweak(name: "Disable Liquid Glass", detail: "Revert to the previous system material", category: .display, minVersion: "26.0", systemImage: "square.on.square"),
    Tweak(name: "Status Bar Style", detail: "Customize status bar appearance", category: .statusBar, minVersion: "17.0", systemImage: "chart.bar"),
    Tweak(name: "Device Model Name", detail: "Change what shows under Settings > General > About", category: .system, minVersion: "17.0", systemImage: "iphone"),
    Tweak(name: "Boot Chime", detail: "Enable the startup chime", category: .misc, minVersion: "17.0", systemImage: "speaker.wave.2"),
    Tweak(name: "Stage Manager", detail: "Enable Stage Manager on unsupported devices", category: .system, minVersion: "17.0", systemImage: "rectangle.3.group"),
]

// MARK: - View model

@MainActor
final class TweaksViewModel: ObservableObject {
    @Published var appliedState: [Tweak.ID: Bool] = [:]
    @Published var inFlight: Set<Tweak.ID> = []
    @Published var errorMessage: String?

    private let backend: TweakBackend

    init(backend: TweakBackend) {
        self.backend = backend
    }

    func refreshAll() async {
        for tweak in knownTweaks {
            appliedState[tweak.id] = await backend.isApplied(tweak)
        }
    }

    func toggle(_ tweak: Tweak, to newValue: Bool) {
        inFlight.insert(tweak.id)
        Task {
            defer { inFlight.remove(tweak.id) }
            do {
                try await backend.apply(tweak, enabled: newValue)
                appliedState[tweak.id] = newValue
            } catch {
                errorMessage = "Couldn't apply \(tweak.name): \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Root view

struct NuggetRootView: View {
    @StateObject private var viewModel: TweaksViewModel
    @State private var searchText = ""

    init(backend: TweakBackend = StubBackend()) {
        _viewModel = StateObject(wrappedValue: TweaksViewModel(backend: backend))
    }

    private var filteredTweaks: [Tweak] {
        guard !searchText.isEmpty else { return knownTweaks }
        return knownTweaks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.detail.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedTweaks: [(Tweak.Category, [Tweak])] {
        Tweak.Category.allCases.compactMap { category in
            let items = filteredTweaks.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                DeviceHeaderSection()

                ForEach(groupedTweaks, id: \.0) { category, tweaks in
                    Section(category.rawValue) {
                        ForEach(tweaks) { tweak in
                            TweakRow(
                                tweak: tweak,
                                isOn: Binding(
                                    get: { viewModel.appliedState[tweak.id] ?? false },
                                    set: { viewModel.toggle(tweak, to: $0) }
                                ),
                                isLoading: viewModel.inFlight.contains(tweak.id)
                            )
                        }
                    }
                }
            }
            .navigationTitle("Tweaks")
            .searchable(text: $searchText, prompt: "Search tweaks")
            .task { await viewModel.refreshAll() }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Subviews

private struct DeviceHeaderSection: View {
    var body: some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 34))
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(UIDevice.current.name)
                        .font(.headline)
                    Text("iOS \(UIDevice.current.systemVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

private struct TweakRow: View {
    let tweak: Tweak
    @Binding var isOn: Bool
    let isLoading: Bool

    var body: some View {
        HStack {
            Image(systemName: tweak.systemImage)
                .frame(width: 28)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(tweak.name)
                Text(tweak.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isLoading {
                ProgressView()
            } else {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NuggetRootView()
}
