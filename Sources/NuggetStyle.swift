import SwiftUI

enum NuggetStyle {
    static let accent = Color(red: 0.02, green: 0.56, blue: 1.0)
    static let background = Color.black
    static let card = Color(uiColor: .secondarySystemGroupedBackground)
    static let muted = Color(uiColor: .secondaryLabel)
}

extension View {
    func nuggetListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(NuggetStyle.background)
            .environment(\.defaultMinListRowHeight, 58)
    }
}
