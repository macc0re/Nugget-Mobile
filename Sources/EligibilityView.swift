import SwiftUI

struct EligibilityView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        List {
            Section("AI ENABLER") {
                infoToggle("Enable Apple Intelligence", id: "eligibility.appleIntelligence")
                infoToggle("Spoof Device Model", id: "eligibility.spoofModel")
            }
        }
        .nuggetListStyle()
        .navigationTitle("Eligibility")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolDetailToolbar(isVerified: state.gestaltVerified) }
    }

    private func infoToggle(_ title: String, id: String) -> some View {
        HStack(spacing: 12) {
            Toggle(title, isOn: state.binding(for: id))
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundStyle(NuggetStyle.accent)
        }
    }
}

#Preview {
    NavigationStack { EligibilityView() }
        .environmentObject(AppState())
}
