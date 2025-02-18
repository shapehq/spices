import SwiftUI

struct ChildVariableStoreMenuItemView: View {
    let parameters: MenuItem.VariableStoreParameters
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            MenuItemListView(
                items: MenuItem.all(from: parameters.variableStore),
                title: parameters.variableStore.name,
                dismiss: dismiss
            )
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text(parameters.variableStore.name)
        }
    }
}
