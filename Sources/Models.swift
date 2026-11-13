//
//  Models.swift
//  Toggle model + backend abstraction. No write/exploit logic lives here —
//  `TweakBackend` is a seam you implement separately.
//

import Foundation

/// A single on/off setting shown in a tool page.
struct ToggleItem: Identifiable {
    let id: String          // stable key, e.g. "gestalt.bootChime"
    let title: String
    var subtitle: String? = nil   // e.g. warning text
    var isOn: Bool = false
}

/// A row that opens a picker instead of a plain toggle (e.g. Dynamic Island style).
struct PickerItem: Identifiable {
    let id: String
    let title: String
    var selection: String = "Default"
    let options: [String]
}

/// Abstraction over "however a tweak actually gets written to disk."
/// Stub only — plug in your real implementation at the call site.
protocol TweakBackend {
    func currentValues() async -> [String: Bool]
    func setToggle(_ id: String, to value: Bool) async throws
    func applyAll() async throws
    func removeAll() async throws
}

struct StubBackend: TweakBackend {
    func currentValues() async -> [String: Bool] { [:] }
    func setToggle(_ id: String, to value: Bool) async throws {
        print("TODO: set \(id) -> \(value)")
    }
    func applyAll() async throws { print("TODO: apply all tweaks") }
    func removeAll() async throws { print("TODO: remove all tweaks") }
}
