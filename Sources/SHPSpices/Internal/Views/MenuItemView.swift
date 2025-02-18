import SwiftUI

struct MenuItemView: View {
    let menuItem: MenuItem
    let dismiss: () -> Void

    var body: some View {
        switch menuItem {
        case .toggle(let parameters):
            ToggleMenuItemView(parameters: parameters)
        case .picker(let parameters):
            PickerMenuItemView(parameters: parameters)
        case .button(let parameters):
            ButtonMenuItemView(parameters: parameters)
        case .variableStore(let parameters):
            ChildVariableStoreMenuItemView(parameters: parameters, dismiss: dismiss)
        }
    }
}
