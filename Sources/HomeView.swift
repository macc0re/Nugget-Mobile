import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("VERSION 2.0.1 (RELEASE)", systemImage: "info.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(NuggetStyle.muted)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    actionRow(title: "Apply Tweaks", tint: NuggetStyle.accent) {
                        state.applyTweaks()
                    }

                    actionRow(title: "Remove All Tweaks", tint: .red) {
                        state.removeAllTweaks()
                    }
                } header: {
                    Label("TWEAK OPTIONS", systemImage: "hammer")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nugget Mobile")
                            .font(.headline)
                        Text("A mobile interface for device customization.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Based on the original Nugget project by leminlimez.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                } header: {
                    Label("CREDITS", systemImage: "wrench.and.screwdriver")
                }
            }
            .nuggetListStyle()
            .navigationTitle("Nugget")
            .navigationBarTitleDisplayMode(.large)
            .task { await state.refresh() }
            .alert("Nugget", isPresented: Binding(
                get: { state.noticeMessage != nil },
                set: { if !$0 { state.noticeMessage = nil } }
            )) {
                Button("OK") { state.noticeMessage = nil }
            } message: {
                Text(state.noticeMessage ?? "")
            }
        }
    }

    private func actionRow(title: String, tint: Color, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Button(action: action) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 68)
                    .foregroundStyle(tint)
                    .background(tint.opacity(0.20), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
