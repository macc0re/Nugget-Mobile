import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("VERSION 2.0.1 (RELEASE)", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)

                Section {
                    actionRow(title: "Apply Tweaks", tint: .blue) {
                        state.applyTweaks()
                    }
                    actionRow(title: "Remove All Tweaks", tint: .red) {
                        state.removeAllTweaks()
                    }

                    Toggle("Auto reboot after apply", isOn: $state.autoRebootAfterApply)
                } header: {
                    Label("TWEAK OPTIONS", systemImage: "hammer")
                }

                Section {
                    Text("Based on the original Nugget project by leminlimez.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Label("CREDITS", systemImage: "wrench.and.screwdriver")
                }
            }
            .navigationTitle("Nugget")
            .task { await state.refresh() }
            .overlay {
                if state.isApplying {
                    ProgressView().controlSize(.large)
                }
            }
            .alert("Error", isPresented: .constant(state.errorMessage != nil)) {
                Button("OK") { state.errorMessage = nil }
            } message: {
                Text(state.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private func actionRow(title: String, tint: Color, action: @escaping () -> Void) -> some View {
        HStack {
            Button(action: action) {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(tint.opacity(0.25))
            .foregroundStyle(tint)

            Button {
                // Hook up an info sheet/popover here if you want the (i) detail text.
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.bordered)
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
