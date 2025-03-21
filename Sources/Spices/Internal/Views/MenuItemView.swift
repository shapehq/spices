import SwiftUI

struct MenuItemView: View {
    let menuItem: any MenuItem
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
            AsyncButtonMenuItemView(menuItem: menuItem)
        } else if let menuItem = menuItem as? ChildSpiceStoreMenuItem {
            ChildSpiceStoreMenuItemView(menuItem: menuItem, dismiss: dismiss)
        } else if let menuItem = menuItem as? ViewMenuItem {
            ViewMenuItemView(menuItem: menuItem)
        } else {
            fatalError("Unknown menu item of type \(type(of: menuItem))")
        }
    }
}
