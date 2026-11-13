import SwiftUI

struct ToolsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("SPARSERESTORE TWEAKS") {
                    NavigationLink {
                        MobileGestaltView()
                    } label: {
                        Label("Mobile Gestalt", systemImage: "iphone.gen3")
                    }
                    NavigationLink {
                        FeatureFlagsView()
                    } label: {
                        Label("Feature Flags", systemImage: "flag")
                    }
                    NavigationLink {
                        EligibilityView()
                    } label: {
                        Label("Eligibility", systemImage: "key")
                    }
                    NavigationLink {
                        SpringBoardTweaksView()
                    } label: {
                        Label("SpringBoard", systemImage: "square.on.square")
                    }
                    NavigationLink {
                        InternalOptionsView()
                    } label: {
                        Label("Internal Options", systemImage: "internaldrive")
                    }
                }

                Section("DOMAIN RESTORE TWEAKS (REQUIRES SKIP SETUP)") {
                    NavigationLink {
                        StatusBarView()
                    } label: {
                        Label("Status Bar", systemImage: "wifi")
                    }
                }
            }
            .navigationTitle("Tools")
        }
    }
}

#Preview {
    ToolsView().environmentObject(AppState())
}
