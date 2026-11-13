import SwiftUI

struct FeatureFlagsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        List {
            Section {
                Toggle("Toggle Lockscreen Clock Animation", isOn: state.binding(for: "flags.lockscreenClockAnim"))
                Toggle("Toggle Duplicate Lockscreen Button and Lockscreen Quickswitch", isOn: state.binding(for: "flags.duplicateLockscreenButton"))
                Toggle("Enable Old Photo UI", isOn: state.binding(for: "flags.oldPhotoUI"))
                Toggle("Enable Apple Intelligence", isOn: state.binding(for: "flags.appleIntelligence"))
            }
        }
        .nuggetListStyle()
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolDetailToolbar(isVerified: state.gestaltVerified) }
    }
}

#Preview {
    NavigationStack { FeatureFlagsView() }
        .environmentObject(AppState())
}
