import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("SPARSERESTORE TWEAKS") {
                    toolLink("Mobile Gestalt", icon: "iphone.gen3") {
                        MobileGestaltView()
                    }
                    toolLink("Feature Flags", icon: "flag") {
                        FeatureFlagsView()
                    }
                    toolLink("Eligibility", icon: "key.vertical") {
                        EligibilityView()
                    }
                    toolLink("SpringBoard", icon: "rectangle.on.rectangle") {
                        SpringBoardTweaksView()
                    }
                    toolLink("Internal Options", icon: "internaldrive") {
                        InternalOptionsView()
                    }
                }

                Section {
                    toolLink("Status Bar", icon: "wifi") {
                        StatusBarView()
                    }
                } header: {
                    Text("DOMAIN RESTORE TWEAKS")
                } footer: {
                    Text("Requires Skip Setup.")
                }
            }
            .nuggetListStyle()
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func toolLink<Destination: View>(
        _ title: String,
        icon: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            Label {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(NuggetStyle.accent)
                    .frame(width: 34)
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    ToolsView().environmentObject(AppState())
}
