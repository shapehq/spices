import SwiftUI

public struct VariableEditor: View {
    private let variableStore: any VariableStore
    @Environment(\.dismiss) private var dismiss

    public init(editing variableStore: any VariableStore) {
        self.variableStore = variableStore
    }

    public var body: some View {
        NavigationView {
            MenuItemListView(items: MenuItem.all(from: variableStore), title: "Variables") {
                dismiss()
            }
        }
        .configureSheetPresentation()
    }
}
