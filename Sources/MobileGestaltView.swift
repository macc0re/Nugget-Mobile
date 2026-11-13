import SwiftUI

struct MobileGestaltView: View {
    @EnvironmentObject private var state: AppState

    private let dynamicIslandOptions = [
        "Default",
        "iPhone 14 Pro Dynamic Island",
        "iPhone 14 Pro Max Dynamic Island",
        "iPhone 16 Pro Dynamic Island",
        "iPhone 16 Pro Max Dynamic Island"
    ]

    @State private var dynamicIslandSelection = "Default"
    @State private var deviceModelName = ""

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: "iphone")
                        .font(.title2)
                        .foregroundStyle(NuggetStyle.accent)
                        .frame(width: 34)

                    Text("Gestures / Dynamic Island")
                        .font(.body.weight(.semibold))

                    Spacer(minLength: 8)

                    Picker("Dynamic Island", selection: $dynamicIslandSelection) {
                        ForEach(dynamicIslandOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .labelsHidden()
                    .tint(NuggetStyle.accent)
                }
                .padding(.vertical, 5)

                Toggle("Fix rdar (modifies resolution)", isOn: state.binding(for: "gestalt.fixRdar"))

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Change Device Model Name", isOn: state.binding(for: "gestalt.changeModelName"))
                    TextField("Device Model Name", text: $deviceModelName)
                        .disabled(!(state.toggles["gestalt.changeModelName"] ?? false))
                        .foregroundStyle(.secondary)
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
                warnedToggle("Enable Stage Manager Supported", warning: "Risky on some devices, mainly phones", id: "gestalt.stageManager")
                warnedToggle("Enable Medusa (iPad Multitasking)", warning: "May be risky on phones", id: "gestalt.medusa")
                Toggle("Allow iPad Apps on iPhone", isOn: state.binding(for: "gestalt.ipadApps"))
                Toggle("Disable Region Restrictions (ie. Shutter Sound)", isOn: state.binding(for: "gestalt.regionRestrictions"))
                Toggle("Enable Apple Pencil", isOn: state.binding(for: "gestalt.applePencil"))
                Toggle("Toggle Action Button", isOn: state.binding(for: "gestalt.actionButton"))
            }

            Section {
                warnedToggle("Toggle Internal Storage", warning: "Risky for some devices, mainly iPads", id: "gestalt.internalStorage")
                Toggle("Set as Apple Internal Install (ie Metal HUD in any app)", isOn: state.binding(for: "gestalt.appleInternal"))
                Toggle("Always On Display", isOn: state.binding(for: "gestalt.aod"))
            }
        }
        .nuggetListStyle()
        .navigationTitle("Mobile Gestalt")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolDetailToolbar(isVerified: state.gestaltVerified)
        }
    }

    private func warnedToggle(_ title: String, warning: String, id: String) -> some View {
        Toggle(isOn: state.binding(for: id)) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                Text("WARNING: " + warning)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    NavigationStack { MobileGestaltView() }
        .environmentObject(AppState())
}
