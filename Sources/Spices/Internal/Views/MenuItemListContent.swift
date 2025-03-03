import SwiftUI

struct MenuItemListContent: View {
    let menuItems: [MenuItem]
    let dismiss: () -> Void

    var body: some View {
        ForEach(menuItems, id: \.id) { menuItem in
            MenuItemView(menuItem: menuItem, dismiss: dismiss)
        }
    }
}
