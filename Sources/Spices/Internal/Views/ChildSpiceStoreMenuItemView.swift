import SwiftUI

struct ChildSpiceStoreMenuItemView: View {
    let menuItem: ChildSpiceStoreMenuItem
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            MenuItemListView(
                items: menuItem.spiceStore.menuItems,
                title: menuItem.spiceStore.name,
                dismiss: dismiss
            )
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text(menuItem.spiceStore.name)
        }
    }
}
