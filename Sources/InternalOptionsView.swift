import SwiftUI

struct InternalOptionsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        List {
            Section {
                Toggle("Show Build Version in Status Bar", isOn: state.binding(for: "internal.showBuildVersion"))
                Toggle("Force Right-to-Left Layout", isOn: state.binding(for: "internal.forceRTL"))
                Toggle("Enable Metal HUD Debug", isOn: state.binding(for: "internal.metalHUDDebug"))
                Toggle("Enable Accessory Debugging", isOn: state.binding(for: "internal.accessoryDebug"))
                Toggle("Enable iMessage Debugging", isOn: state.binding(for: "internal.imessageDebug"))
                Toggle("Enable Continuity Debugging", isOn: state.binding(for: "internal.continuityDebug"))
                Toggle("Enable FaceTime Debugging", isOn: state.binding(for: "internal.facetimeDebug"))
                Toggle("Enable App Store Debug Gesture", isOn: state.binding(for: "internal.appStoreDebugGesture"))
                Toggle("Enable Notes App Debug Mode", isOn: state.binding(for: "internal.notesDebugMode"))
                Toggle("Show Touches With Debug Info", isOn: state.binding(for: "internal.showTouches"))
                Toggle("Hide Respring Icon", isOn: state.binding(for: "internal.hideRespringIcon"))
                Toggle("Vibrate on Raise-to-Wake", isOn: state.binding(for: "internal.vibrateRaiseToWake"))
                Toggle("Play Sound on Paste", isOn: state.binding(for: "internal.playSoundOnPaste"))
                Toggle("Show Notifications for System Pastes", isOn: state.binding(for: "internal.showPasteNotifications"))
            }
        }
        .nuggetListStyle()
        .navigationTitle("Internal Options")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolDetailToolbar(isVerified: state.gestaltVerified) }
    }
}

#Preview {
    NavigationStack { InternalOptionsView() }
        .environmentObject(AppState())
}
