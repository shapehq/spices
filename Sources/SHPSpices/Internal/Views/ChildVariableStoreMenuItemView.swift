import SwiftUI

struct ChildVariableStoreMenuItemView: View {
    let variableStore: any VariableStore
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            MenuItemListView(
                items: MenuItem.all(from: variableStore),
                title: variableStore.name,
                dismiss: dismiss
            )
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text(variableStore.name)
        }
    }
}
