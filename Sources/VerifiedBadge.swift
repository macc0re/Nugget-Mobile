import SwiftUI

/// The checkmark / X badge shown next to "Modify" on each tool detail page,
/// reflecting whether the current gestalt state is considered valid.
struct VerifiedBadge: View {
    let isVerified: Bool

    var body: some View {
        Image(systemName: isVerified ? "checkmark.seal" : "xmark.seal")
            .foregroundStyle(isVerified ? .green : .red)
    }
}

/// Standard toolbar content for a tool detail page: "Modify" + verified badge.
struct ToolDetailToolbar: ToolbarContent {
    let isVerified: Bool
    var onModify: () -> Void = {}

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                Button("Modify", action: onModify)
                VerifiedBadge(isVerified: isVerified)
            }
        }
    }
}
