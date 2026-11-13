import SwiftUI

struct SpringBoardTweaksView: View {
    @EnvironmentObject private var state: AppState
    @State private var footnoteText = ""

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lock Screen Footnote Text")
                    TextField("Footnote Text", text: $footnoteText)
                }
                Toggle("Disable Lock After Respring", isOn: state.binding(for: "springboard.disableLockAfterRespring"))
                Toggle("Disable Screen Dimming While Charging", isOn: state.binding(for: "springboard.disableDimWhileCharging"))
                Toggle("Disable Low Battery Alerts", isOn: state.binding(for: "springboard.disableLowBatteryAlerts"))
                Toggle("Disable Breadcrumb", isOn: state.binding(for: "springboard.disableBreadcrumb"))
                Toggle("Show Supervision Text on Lock Screen", isOn: state.binding(for: "springboard.showSupervisionText"))
                Toggle("Disable CC Presentation Gesture", isOn: state.binding(for: "springboard.disableCCGesture"))
                Toggle("Enable AirPlay support for Stage Manager", isOn: state.binding(for: "springboard.airplayStageManager"))
            }
        }
        .nuggetListStyle()
        .navigationTitle("SpringBoard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolDetailToolbar(isVerified: state.gestaltVerified) }
    }
}

#Preview {
    NavigationStack { SpringBoardTweaksView() }
        .environmentObject(AppState())
}
