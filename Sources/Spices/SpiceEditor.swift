import SwiftUI

public struct SpiceEditor: View {
    private let spiceStore: any SpiceStore
    @Environment(\.dismiss) private var dismiss

    public init(editing spiceStore: any SpiceStore) {
        self.spiceStore = spiceStore
    }

    public var body: some View {
        NavigationView {
            MenuItemListView(items: MenuItem.all(from: spiceStore), title: "Debug Menu") {
                dismiss()
            }
        }
        .configureSheetPresentation()
    }
}
