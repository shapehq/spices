import SwiftUI

struct ChildSpiceStoreMenuItemView: View {
    let parameters: MenuItem.SpiceStoreParameters
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            MenuItemListView(
                items: MenuItem.all(from: parameters.spiceStore),
                title: parameters.spiceStore.name,
                dismiss: dismiss
            )
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text(parameters.spiceStore.name)
        }
    }
}
