import SwiftUI

struct EligibilityView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        List {
            Section("AI ENABLER") {
                infoToggle("Enable Apple Intelligence", id: "eligibility.appleIntelligence")
                infoToggle("Spoof Device Model", id: "eligibility.spoofModel")
            }
        }
        .navigationTitle("Eligibility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolDetailToolbar(isVerified: state.gestaltVerified)
        }
    }

    @ViewBuilder
    private func infoToggle(_ title: String, id: String) -> some View {
        HStack {
            Toggle(title, isOn: state.binding(for: id))
            Button {
                // Hook up an info popover with the tweak's explanation here.
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
        }
    }
}

#Preview {
    NavigationStack { EligibilityView() }
        .environmentObject(AppState())
}
