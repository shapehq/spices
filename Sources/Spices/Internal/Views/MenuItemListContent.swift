import SwiftUI

struct MenuItemListContent: View {
    let menuItems: [MenuItem]
    @Binding var enableUserInteraction: Bool
    let dismiss: () -> Void

    var body: some View {
        ForEach(menuItems, id: \.id) { menuItem in
            MenuItemView(
                menuItem: menuItem,
                enableUserInteraction: $enableUserInteraction,
                dismiss: dismiss
            )
        }
    }
}
