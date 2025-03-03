import SwiftUI

struct ChildSpiceStoreMenuItemView: View {
    let menuItem: ChildSpiceStoreMenuItem
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            MenuItemListView(
                sections: menuItem.spiceStore.menuItemSections,
                title: menuItem.name.rawValue,
                dismiss: dismiss
            )
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text(menuItem.name.rawValue)
        }
    }
}
