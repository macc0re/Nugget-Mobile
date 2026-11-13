import SwiftUI

struct FeatureFlagsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        List {
            Section {
                Toggle("Toggle Lockscreen Clock Animation", isOn: state.binding(for: "flags.lockscreenClockAnim"))
                Toggle("Toggle Duplicate Lockscreen Button and Lockscreen Quickswitch", isOn: state.binding(for: "flags.duplicateLockscreenButton"))
                Toggle("Enable Old Photo UI", isOn: state.binding(for: "flags.oldPhotoUI"))
                Toggle("Enable Apple Intelligence", isOn: state.binding(for: "flags.appleIntelligence"))
            }
        }
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolDetailToolbar(isVerified: state.gestaltVerified)
        }
    }
}

#Preview {
    NavigationStack { FeatureFlagsView() }
        .environmentObject(AppState())
}
