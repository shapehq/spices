import SwiftUI

struct MenuItemView: View {
    let menuItem: any MenuItem
    @Binding var enableUserInteraction: Bool
    let dismiss: () -> Void

    var body: some View {
        if let menuItem = menuItem as? ToggleMenuItem {
            ToggleMenuItemView(menuItem: menuItem)
        } else if let menuItem = menuItem as? PickerMenuItem {
            PickerMenuItemView(menuItem: menuItem)
        } else if let menuItem = menuItem as? TextFieldMenuItem {
            TextFieldMenuItemView(menuItem: menuItem)
        } else if let menuItem = menuItem as? ButtonMenuItem {
            ButtonMenuItemView(menuItem: menuItem)
        } else if let menuItem = menuItem as? AsyncButtonMenuItem {
            AsyncButtonMenuItemView(menuItem: menuItem, enableUserInteraction: $enableUserInteraction)
        } else if let menuItem = menuItem as? ChildSpiceStoreMenuItem {
            ChildSpiceStoreMenuItemView(menuItem: menuItem, dismiss: dismiss)
        } else {
            fatalError("Unknown menu item of type \(type(of: menuItem))")
        }
    }
}
