import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        List {
            Section {
                Toggle("Custom Carrier Text", isOn: state.binding(for: "statusbar.customCarrierText"))
                Toggle("Hide Status Bar Items", isOn: state.binding(for: "statusbar.hideItems"))
            } footer: {
                Text("Requires Skip Setup to apply via domain restore.")
            }
        }
        .nuggetListStyle()
        .navigationTitle("Status Bar")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolDetailToolbar(isVerified: state.gestaltVerified) }
    }
}

#Preview {
    NavigationStack { StatusBarView() }
        .environmentObject(AppState())
}
