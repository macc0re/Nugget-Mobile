import SwiftUI

struct MobileGestaltView: View {
    @EnvironmentObject var state: AppState

    private let dynamicIslandOptions = [
        "Default", "iPhone 16 Pro Dynamic Island", "iPhone 16 Pro Max Dynamic Island"
    ]

    var body: some View {
        List {
            Section {
                Picker("Gestures / Dynamic Island", selection: $dynamicIslandSelection) {
                    ForEach(dynamicIslandOptions, id: \.self) { Text($0) }
                }

                Toggle("Fix rdar (modifies resolution)", isOn: state.binding(for: "gestalt.fixRdar"))

                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Change Device Model Name", isOn: state.binding(for: "gestalt.changeModelName"))
                    TextField("Device Model Name", text: .constant(""))
                        .foregroundStyle(.secondary)
                        .disabled(!(state.toggles["gestalt.changeModelName"] ?? false))
                }
            }

            Section {
                Toggle("Enable Boot Chime", isOn: state.binding(for: "gestalt.bootChime"))
                Toggle("Enable Charge Limit", isOn: state.binding(for: "gestalt.chargeLimit"))
                Toggle("Enable Collision SOS", isOn: state.binding(for: "gestalt.collisionSOS"))
                Toggle("Enable Tap to Wake (iPhone SE)", isOn: state.binding(for: "gestalt.tapToWake"))
                Toggle("Enable iPhone 16 Camera Button Settings", isOn: state.binding(for: "gestalt.cameraButton"))
                Toggle("Disable Wallpaper Parallax", isOn: state.binding(for: "gestalt.disableParallax"))
            }

            Section {
                warnedToggle("Enable Stage Manager Supported", warning: "risky on some devices, mainly phones", id: "gestalt.stageManager")
                warnedToggle("Enable Medusa (iPad Multitasking)", warning: "may be risky on phones", id: "gestalt.medusa")
                Toggle("Allow iPad Apps on iPhone", isOn: state.binding(for: "gestalt.ipadApps"))
                Toggle("Disable Region Restrictions (ie. Shutter Sound)", isOn: state.binding(for: "gestalt.regionRestrictions"))
                Toggle("Enable Apple Pencil", isOn: state.binding(for: "gestalt.applePencil"))
                Toggle("Toggle Action Button", isOn: state.binding(for: "gestalt.actionButton"))
            }

            Section {
                warnedToggle("Toggle Internal Storage", warning: "risky for some devices, mainly iPads", id: "gestalt.internalStorage")
                Toggle("Set as Apple Internal Install (ie Metal HUD in any app)", isOn: state.binding(for: "gestalt.appleInternal"))
                Toggle("Always On Display", isOn: state.binding(for: "gestalt.aod"))
            }
        }
        .navigationTitle("Mobile Gestalt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolDetailToolbar(isVerified: state.gestaltVerified)
        }
    }

    // Local state for the Dynamic Island picker; swap for a @State var if you
    // don't want it round-tripping through the generic toggle store.
    @State private var dynamicIslandSelection = "Default"

    @ViewBuilder
    private func warnedToggle(_ title: String, warning: String, id: String) -> some View {
        Toggle(isOn: state.binding(for: id)) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text("WARNING: \(warning)")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    NavigationStack { MobileGestaltView() }
        .environmentObject(AppState())
}
